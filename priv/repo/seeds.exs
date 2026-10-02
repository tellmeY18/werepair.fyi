alias Werepair.{Repo, Accounts, Repairs, Events, Community}
alias Werepair.Accounts.User
import Ecto.Query
Logger.configure(level: :warning)

unless Application.get_env(:werepair, :demo), do: raise("Demo seeds require DEMO=true")

if Repo.exists?(from u in User, where: u.email == "admin@example.test") do
  IO.puts("Demo already seeded; leaving existing records unchanged.")
else
  Repo.transaction(fn ->
    create_user = fn name, email, technician, area, skills ->
      {:ok, user} =
        Accounts.register(%{
          name: name,
          email: email,
          password: "RepairDemo2026!",
          phone: "+910000000000",
          area: area,
          adult: true,
          technician: technician,
          skills: skills,
          bio: "Fictional demo profile for the Kochi repair community.",
          availability: "Weekends at community repair events",
          latitude: 9.9816,
          longitude: 76.2999
        })

      user
    end

    admin =
      create_user.("Demo Organiser", "admin@example.test", false, "Kochi", nil)
      |> Ecto.Changeset.change(admin: true)
      |> Repo.update!()

    asha = create_user.("Asha Nair", "asha@example.test", false, "Kaloor", nil)

    ravi =
      create_user.(
        "Ravi Menon",
        "ravi@example.test",
        true,
        "Ernakulam",
        "Electronics, radios, small appliances"
      )

    meera = create_user.("Meera Joseph", "meera@example.test", false, "Edappally", nil)

    names = [
      "Anil Kumar",
      "Binu Thomas",
      "Chitra Das",
      "Deepa Varma",
      "Faisal Ali",
      "Geetha Nair",
      "Hari Krishnan",
      "Indu Paul",
      "Jaya Mathew",
      "Kiran Babu",
      "Leena George",
      "Manu Raj",
      "Nisha Peter",
      "Omar Basheer",
      "Priya Das",
      "Rajesh Pillai",
      "Sara John",
      "Tina Roy",
      "Vinu Dev"
    ]

    areas = ["Fort Kochi", "Edappally", "Kaloor", "Palarivattom", "Kakkanad", "Vyttila"]

    skills = [
      "Bicycles, punctures",
      "Clothing, sewing",
      "Furniture, carpentry",
      "Electronics, laptops",
      "Appliances, fans",
      "Other, umbrellas"
    ]

    for {name, i} <- Enum.with_index(names, 1) do
      create_user.(
        name,
        "tech#{i}@example.test",
        true,
        Enum.at(areas, rem(i, 6)),
        Enum.at(skills, rem(i, 6))
      )
    end

    create_request = fn title, category ->
      {:ok, request} =
        Repairs.create(asha, %{
          "title" => title,
          "description" =>
            "Demo item: #{title}. The owner wants to repair it and learn the diagnosis.",
          "tried" =>
            "Stopped using it and checked the outside for visible damage. No hazardous work attempted.",
          "category" => category,
          "area" => "Kaloor",
          "mode" => "At an event",
          "document_consent" => "true"
        })

      request
    end

    repair = fn request, outcome ->
      {:ok, _} =
        Repairs.add_entry(ravi, request.id, "comment", %{
          "body" =>
            "I can inspect this with you at the repair event. We will agree a price before work.",
          "price" => "250"
        })

      {:ok, _} = Repairs.choose(asha, request.id, ravi.id)

      {:ok, _} =
        Repairs.add_entry(asha, request.id, "log", %{
          "body" =>
            "We inspected the item together. Ravi explained the diagnosis, replaced the worn part and tested the result. I learned how to spot the fault next time.",
          "parts" => "Replacement clip",
          "purchased_by" => "Requester",
          "price" => "250"
        })

      {:ok, _} =
        Repairs.transition(asha, request.id, %{
          "status" => outcome,
          "outcome_note" =>
            "#{outcome}: demonstrated and checked together; old parts returned to owner."
        })

      {:ok, _} = Repairs.confirm(ravi, request.id, %{"credit_consent" => "true"})

      {:ok, _} =
        Repairs.transition(asha, request.id, %{
          "status" => "closed",
          "outcome_note" => "Repair documented; thank you for teaching me."
        })

      {:ok, _} =
        Repairs.review(asha, request.id, %{
          "stars" => "5",
          "body" => "Explained each step clearly."
        })

      {:ok, _} =
        Repairs.review(ravi, request.id, %{
          "stars" => "5",
          "body" => "Prepared the item and documented the work."
        })

      Repairs.get!(request.id)
    end

    closed =
      for {title, category, outcome} <- [
            {"Radio tuning knob", "Electronics", "fixed"},
            {"Loose chair joint", "Furniture", "fixed"},
            {"Backpack zipper", "Clothing", "fixed"},
            {"Bicycle mudguard", "Bicycles", "partly"},
            {"Cracked umbrella frame", "Other", "not_fixed"}
          ],
          do: repair.(create_request.(title, category), outcome)

    today = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    event_attrs = %{
      "title" => "Kochi Community Repair Fest — DEMO",
      "theme" => "Electronics, bicycles, clothing and small household items",
      "venue" => "Demo community hall, Ernakulam (fictional venue)",
      "starts_at" => NaiveDateTime.add(today, 7 * 86400),
      "latitude" => 9.9816,
      "longitude" => 76.2999,
      "rules" =>
        "Demo event. Owners stay with their items. Qualified technicians handle hazardous work. Apprentices stay supervised. Organiser checks venue permission, power isolation, fire safety and first aid. Take items and replaced parts home."
    }

    {:ok, upcoming} = Events.create(admin, event_attrs)

    {:ok, past} =
      Events.create(
        admin,
        Map.merge(event_attrs, %{
          "title" => "September Repair Café — DEMO",
          "starts_at" => NaiveDateTime.add(today, -7 * 86400)
        })
      )

    for event <- [upcoming, past] do
      {:ok, tech} =
        Events.join(ravi, event.id, %{
          "kind" => "technician",
          "note" => "Radios and small appliances; two learner places.",
          "consent" => "true"
        })

      {:ok, apprentice} =
        Events.join(meera, event.id, %{
          "kind" => "apprentice",
          "mentor_id" => ravi.id,
          "note" => "I want to learn fault diagnosis and safe tool use.",
          "consent" => "true"
        })

      {:ok, owner} =
        Events.join(asha, event.id, %{
          "kind" => "requester",
          "note" => "Bringing an item and staying to learn.",
          "consent" => "true"
        })

      if event.id == past.id do
        {:ok, _} = Events.record(admin, event.id, tech.id, %{"status" => "attended"})
        {:ok, _} = Events.record(admin, event.id, owner.id, %{"status" => "attended"})

        {:ok, _} =
          Events.record(ravi, event.id, apprentice.id, %{"status" => "attended", "hours" => "4"})

        for request <- closed, do: Repo.update!(Ecto.Changeset.change(request, event_id: past.id))

        {:ok, _} =
          Events.complete(admin, event.id, %{
            "summary" =>
              "Five demo items examined: three fixed, one partly fixed, one not repairable. Meera completed four supervised learning hours. Owners documented outcomes and prepared five journal drafts."
          })
      end
    end

    open = create_request.("Desk fan makes a rattling sound", "Appliances")
    {:ok, _} = Events.register_item(asha, upcoming.id, open.id)
    talks = create_request.("Laptop hinge needs attention", "Electronics")

    {:ok, _} =
      Repairs.add_entry(ravi, talks.id, "comment", %{
        "body" => "I can inspect the hinge at the fest. Please back up the laptop first."
      })

    progress = create_request.("Sewing machine handwheel sticks", "Appliances")

    {:ok, _} =
      Repairs.add_entry(ravi, progress.id, "comment", %{
        "body" => "Let's inspect it together before ordering any parts."
      })

    {:ok, _} = Repairs.choose(asha, progress.id, ravi.id)
    create_request.("Learn to patch a bicycle tube", "Bicycles")
    cancelled = create_request.("Old kettle — cancelled demo", "Appliances")

    {:ok, _} =
      Repairs.transition(asha, cancelled.id, %{
        "status" => "cancelled",
        "outcome_note" => "Owner could not attend; no work started."
      })

    {:ok, spam} =
      Repairs.add_entry(meera, open.id, "comment", %{
        "body" => "DEMO MODERATION: a simulated advance-payment demand, ready for removal."
      })

    {:ok, _} =
      Community.report(asha, "comment", spam.id, %{
        "reason" => "Demo report: asks for payment before inspecting the item."
      })

    for {description, kind, amount, payer} <- [
          {"DEMO domain registration", "expense", "1200", "Organiser"},
          {"DEMO local hosting", "expense", "0", "In-kind hosting"},
          {"DEMO community contribution", "donation", "500", "Anonymous supporter"}
        ] do
      {:ok, _} =
        Community.add_cost(admin, %{
          date: Date.utc_today(),
          description: description,
          kind: kind,
          amount: amount,
          paid_by: payer
        })
    end
  end)

  IO.puts(
    "Seeded: 20 technicians, 10 requests, 2 events, 5 journal-ready repairs, reviews, apprenticeship, report and ledger. Password: RepairDemo2026!"
  )
end
