defmodule WerepairWeb.PlatformFlowTest do
  use WerepairWeb.ConnCase, async: false
  alias Werepair.{Accounts, Repairs, Events, Community, Repo}

  setup do
    user = fn name, attrs ->
      {:ok, user} =
        Accounts.register(
          Map.merge(
            %{
              name: name,
              email: "#{String.downcase(name)}@example.test",
              password: "test-password-123",
              phone: "+919999999999",
              area: "Kochi",
              adult: true
            },
            attrs
          )
        )

      user
    end

    owner = user.("Owner", %{})
    tech = user.("Technician", %{technician: true})
    learner = user.("Learner", %{})
    admin = user.("Admin", %{}) |> Ecto.Changeset.change(admin: true) |> Repo.update!()
    %{owner: owner, tech: tech, learner: learner, admin: admin}
  end

  defp signed(user),
    do:
      build_conn()
      |> init_test_session(%{user_id: user.id, signed_at: System.system_time(:second)})

  defp dom(conn, status \\ 200), do: conn |> html_response(status) |> LazyHTML.from_document()
  defp present?(dom, selector), do: dom |> LazyHTML.query(selector) |> Enum.any?()

  defp request(owner) do
    {:ok, request} =
      Repairs.create(owner, %{
        "title" => "Broken radio",
        "description" => "The tuning knob is loose",
        "area" => "Kaloor",
        "category" => "Electronics",
        "mode" => "At an event",
        "document_consent" => "true"
      })

    request
  end

  defp closed(owner, tech) do
    request = request(owner)
    {:ok, _} = Repairs.add_entry(tech, request.id, "comment", %{"body" => "I can help"})
    {:ok, _} = Repairs.choose(owner, request.id, tech.id)

    {:ok, _} =
      Repairs.transition(owner, request.id, %{
        "status" => "fixed",
        "outcome_note" => "Replaced knob"
      })

    {:ok, _} =
      Repairs.transition(owner, request.id, %{
        "status" => "closed",
        "outcome_note" => "Documented"
      })

    Repairs.get!(request.id)
  end

  defp event(admin) do
    {:ok, event} =
      Events.create(admin, %{
        "title" => "Repair fest",
        "theme" => "Anything",
        "venue" => "Community hall",
        "starts_at" => "2026-11-01T10:00",
        "latitude" => "9.98",
        "longitude" => "76.29",
        "rules" => "Stay supervised"
      })

    event
  end

  test "public pages render without exposing contacts", %{tech: tech, owner: owner} do
    request = request(owner)

    for path <- [
          "/",
          "/technicians",
          "/people/#{tech.id}",
          "/requests",
          "/requests/#{request.id}",
          "/events",
          "/costs",
          "/learn",
          "/about",
          "/sign-in",
          "/register"
        ] do
      page = get(build_conn(), path) |> dom()
      assert present?(page, "#main"), path
      refute LazyHTML.text(page) =~ tech.phone
      refute LazyHTML.text(page) =~ tech.email
    end

    assert redirected_to(get(build_conn(), "/requests/new")) == "/sign-in"
  end

  test "registration protects privileged fields and validates age", %{} do
    attrs = %{
      name: "New Person",
      email: "new@example.test",
      password: "test-password-123",
      phone: "+919999999999",
      area: "Kochi",
      admin: true,
      banned: true
    }

    assert {:error, _} = Accounts.register(attrs)
    conn = post(build_conn(), "/register", user: Map.put(attrs, :adult, true))
    assert redirected_to(conn) == "/profile"
    user = Repo.get_by!(Accounts.User, email: attrs.email)
    refute user.admin
    refute user.banned
    assert user.password_hash != attrs.password
    assert {:ok, _} = Accounts.authenticate("NEW@example.test", attrs.password)
  end

  test "login, expiry and suspension", %{owner: owner, admin: admin} do
    conn =
      post(build_conn(), "/sign-in",
        session: %{email: owner.email, password: "test-password-123"}
      )

    assert redirected_to(conn) == "/profile"
    assert get_session(conn, :user_id) == owner.id
    assert present?(get(recycle(conn), "/profile") |> dom(), "#profile-form")
    profile = get(recycle(conn), "/profile") |> dom()
    refute present?(profile, "#profile-form input[name=_method]")

    assert redirected_to(
             post(signed(owner), "/profile",
               user: %{name: "Updated Owner", area: "Kaloor", phone: owner.phone, admin: true}
             )
           ) == "/profile"

    refute Accounts.get_user!(owner.id).admin
    assert redirected_to(post(recycle(conn), "/sign-out")) == "/"
    invalid = post(build_conn(), "/sign-in", session: %{email: owner.email, password: "bad"})
    assert present?(dom(invalid, 422), "#sign-in-form")

    expired =
      build_conn() |> init_test_session(%{user_id: owner.id, signed_at: 0}) |> get("/profile")

    assert redirected_to(expired) == "/sign-in"
    {:ok, report} = Community.report(admin, "profile", owner.id, %{"reason" => "Test suspension"})
    assert {:ok, _} = Community.resolve(admin, report.id, "removed")
    assert redirected_to(get(signed(owner), "/profile")) == "/sign-in"
    assert {:error, _} = Accounts.authenticate(owner.email, "test-password-123")
    assert_raise Werepair.ForbiddenError, fn -> request(owner) end
  end

  test "complete repair journey through HTTP forms", %{owner: owner, tech: tech} do
    conn =
      post(signed(owner), "/requests",
        request: %{
          title: "Radio knob",
          description: "Loose tuning knob",
          area: "Kaloor",
          category: "Electronics",
          mode: "At an event",
          document_consent: true,
          requester_id: tech.id
        }
      )

    path = redirected_to(conn)
    request = Repo.one!(Werepair.Repairs.Request)
    assert request.requester_id == owner.id
    assert present?(get(signed(owner), path) |> dom(), "#entry-form")

    conn =
      post(signed(tech), path <> "/entries",
        kind: "comment",
        entry: %{body: "I can help", price: "200"}
      )

    assert redirected_to(conn) == path
    assert Repairs.get!(request.id).status == "in_talks"
    assert present?(get(signed(owner), path) |> dom(), "form[id^=choose-]")
    assert redirected_to(post(signed(owner), path <> "/choose", technician_id: tech.id)) == path

    assert redirected_to(
             post(signed(owner), path <> "/entries",
               kind: "log",
               entry: %{
                 body: "Replaced the knob together",
                 parts: "Knob",
                 purchased_by: "Owner",
                 price: "200"
               }
             )
           ) == path

    invalid =
      post(signed(owner), path <> "/status", request: %{status: "fixed", outcome_note: ""})

    assert present?(dom(invalid, 422), "#form-errors")
    assert Repairs.get!(request.id).status == "in_progress"

    for status <- ["fixed", "closed"] do
      assert redirected_to(
               post(signed(owner), path <> "/status",
                 request: %{status: status, outcome_note: "Works again"}
               )
             ) == path
    end

    assert redirected_to(post(signed(tech), path <> "/confirm", request: %{credit_consent: true})) ==
             path

    assert present?(get(signed(owner), path <> "/journal") |> dom(), "#journal-text")

    assert redirected_to(
             post(signed(owner), path <> "/reviews", review: %{stars: 5, body: "Helpful"})
           ) == path

    assert Repairs.public_reviews(Repairs.get!(request.id)) == []
    assert redirected_to(post(signed(tech), path <> "/reviews", review: %{stars: 4})) == path
    assert length(Repairs.public_reviews(Repairs.get!(request.id))) == 2
    assert Community.stats(tech).rating == 5.0
    assert present?(get(build_conn(), path) |> dom(), "article[id^=review-]")
    assert {:error, _} = Repairs.review(owner, request.id, %{"stars" => "5"})
  end

  test "ownership and state transitions cannot be bypassed", %{
    owner: owner,
    tech: tech,
    learner: other
  } do
    request = request(owner)
    assert_raise Werepair.ForbiddenError, fn -> Repairs.choose(owner, request.id, tech.id) end

    assert_raise Werepair.ForbiddenError, fn ->
      Repairs.add_entry(tech, request.id, "log", %{"body" => "forged"})
    end

    assert_raise Werepair.ForbiddenError, fn ->
      Repairs.transition(other, request.id, %{"status" => "cancelled", "outcome_note" => "forged"})
    end

    assert_raise Werepair.ForbiddenError, fn ->
      Repairs.transition(owner, request.id, %{"status" => "closed", "outcome_note" => "skip"})
    end

    assert_raise Werepair.ForbiddenError, fn ->
      Repairs.review(other, request.id, %{"stars" => 5})
    end

    assert_raise Werepair.ForbiddenError, fn -> Events.create(owner, %{}) end
    assert_raise Werepair.ForbiddenError, fn -> Community.add_cost(owner, %{}) end
  end

  test "events support item registration, acceptance, hours and public summary", %{
    owner: owner,
    tech: tech,
    learner: learner,
    admin: admin
  } do
    closed(owner, tech)
    closed(owner, tech)
    event = event(admin)
    path = "/events/#{event.id}"
    assert present?(get(signed(admin), "/events/new") |> dom(), "#event-form")

    assert redirected_to(
             post(signed(tech), path <> "/join",
               participation: %{kind: "technician", note: "Radios", consent: true}
             )
           ) == path

    assert redirected_to(
             post(signed(learner), path <> "/join",
               participation: %{
                 kind: "apprentice",
                 mentor_id: tech.id,
                 note: "Learn diagnosis",
                 consent: true
               }
             )
           ) == path

    participation = Repo.get_by!(Events.Participation, event_id: event.id, user_id: learner.id)
    assert participation.status == "pending"

    assert_raise Werepair.ForbiddenError, fn ->
      Events.record(learner, event.id, participation.id, %{
        "status" => "attended",
        "hours" => "20"
      })
    end

    for attrs <- [%{status: "accepted"}, %{status: "attended", hours: "3"}] do
      assert redirected_to(
               post(signed(tech), path <> "/participations/#{participation.id}",
                 participation: attrs
               )
             ) == path
    end

    assert Community.stats(learner).hours == 3
    request = request(owner)
    assert redirected_to(post(signed(owner), path <> "/items", request_id: request.id)) == path
    assert Repairs.get!(request.id).event_id == event.id
    assert present?(get(signed(tech), path) |> dom(), "#attendance-#{participation.id}")

    assert redirected_to(
             post(signed(admin), path <> "/complete",
               event: %{summary: "A useful day of learning."}
             )
           ) == path

    assert present?(get(build_conn(), path) |> dom(), "#event-summary")
    assert present?(get(build_conn(), "/people/#{learner.id}") |> dom(), "#apprenticeships li")

    assert_raise Werepair.ForbiddenError, fn ->
      Events.join(owner, event.id, %{"kind" => "requester"})
    end
  end

  test "mentoring gates, duplicate signup and attendance validation", %{
    owner: owner,
    tech: tech,
    learner: learner,
    admin: admin
  } do
    event = event(admin)

    assert {:error, _} =
             Events.join(learner, event.id, %{
               "kind" => "apprentice",
               "mentor_id" => "",
               "note" => "Learn",
               "consent" => true
             })

    attrs = %{"kind" => "technician", "note" => "Radios", "consent" => true}
    assert {:ok, _} = Events.join(tech, event.id, attrs)
    assert {:error, _} = Events.join(tech, event.id, attrs)

    assert_raise Werepair.ForbiddenError, fn ->
      Events.join(learner, event.id, %{
        "kind" => "apprentice",
        "mentor_id" => tech.id,
        "note" => "Learn",
        "consent" => true
      })
    end

    closed(owner, tech)
    closed(owner, tech)

    assert {:ok, p} =
             Events.join(learner, event.id, %{
               "kind" => "apprentice",
               "mentor_id" => tech.id,
               "note" => "Learn",
               "consent" => true
             })

    assert {:error, _} =
             Events.record(tech, event.id, p.id, %{"status" => "attended", "hours" => "-1"})

    assert {:error, _} =
             Events.record(tech, event.id, p.id, %{"status" => "attended", "hours" => "0"})
  end

  test "report moderation hides content and protects the admin desk", %{
    owner: owner,
    learner: learner,
    admin: admin
  } do
    request = request(owner)

    {:ok, entry} =
      Repairs.add_entry(learner, request.id, "comment", %{"body" => "Simulated spam"})

    assert redirected_to(
             post(signed(owner), "/reports",
               type: "comment",
               target_id: entry.id,
               report: %{reason: "Spam message"}
             )
           ) == "/"

    [report] = Community.reports(admin)
    assert present?(get(signed(admin), "/admin") |> dom(), "#resolve-#{report.id}")
    assert_raise Werepair.ForbiddenError, fn -> Community.resolve(owner, report.id, "removed") end

    assert redirected_to(post(signed(admin), "/admin/reports/#{report.id}", action: "removed")) ==
             "/admin"

    refute Enum.any?(Repairs.get!(request.id).entries, &(&1.id == entry.id))

    assert redirected_to(
             post(signed(admin), "/admin/costs",
               cost: %{
                 date: "2026-10-01",
                 description: "Hosting",
                 paid_by: "Organiser",
                 kind: "expense",
                 amount: "20"
               }
             )
           ) == "/costs"

    assert present?(get(build_conn(), "/costs") |> dom(), "#cost-ledger tbody tr")
  end

  test "journal excludes private fields and honours technician credit", %{
    owner: owner,
    tech: tech
  } do
    request = closed(owner, tech)
    journal = Werepair.Wiki.journal(request)
    refute journal =~ tech.name
    refute journal =~ owner.email
    refute journal =~ owner.phone
    assert {:ok, _} = Repairs.confirm(tech, request.id, %{"credit_consent" => true})
    assert Werepair.Wiki.journal(Repairs.get!(request.id)) =~ tech.name

    assert {:error, _} =
             Repairs.link_wiki(owner, request.id, %{
               "wiki_url" => "https://wiki.werepair.fyi.evil.test/x"
             })

    assert {:error, _} =
             Repairs.link_wiki(owner, request.id, %{"wiki_url" => "javascript:alert(1)"})

    assert {:ok, _} =
             Repairs.link_wiki(owner, request.id, %{
               "wiki_url" => Werepair.Wiki.page_url("Journal:Demo")
             })
  end
end
