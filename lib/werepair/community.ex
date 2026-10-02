defmodule Werepair.Community do
  import Ecto.Query
  import Ecto.Changeset
  import Werepair.Access

  alias Werepair.{
    Repo,
    Accounts.User,
    Repairs.Request,
    Repairs.Entry,
    Repairs.Review,
    Events.Participation
  }

  alias Werepair.Community.{Report, Cost}

  def stats(user) do
    jobs =
      Repo.aggregate(
        from(r in Request,
          where:
            not r.hidden and not is_nil(r.outcome) and
              (r.requester_id == ^user.id or r.technician_id == ^user.id)
        ),
        :count
      )

    participation =
      Repo.all(
        from p in Participation,
          where: p.user_id == ^user.id and p.status == "attended",
          preload: [:event, :mentor]
      )

    reviews =
      Repo.all(
        from r in Review,
          join: other in Review,
          on: other.request_id == r.request_id and other.author_id != r.author_id,
          where: r.recipient_id == ^user.id and not r.hidden,
          preload: [:author]
      )

    %{
      jobs: jobs,
      events: participation,
      hours: Enum.reduce(participation, 0, &(&1.hours + &2)),
      reviews: reviews,
      rating:
        if(reviews == [],
          do: nil,
          else: Float.round(Enum.sum(Enum.map(reviews, & &1.stars)) / length(reviews), 1)
        ),
      journals:
        Repo.aggregate(
          from(r in Request,
            where: r.requester_id == ^user.id and not r.hidden and not is_nil(r.wiki_url)
          ),
          :count
        )
    }
  end

  # POC policy for the document's open threshold: two completed repairs as technician.
  def mentor?(user),
    do:
      not user.banned and user.technician and
        Repo.aggregate(
          from(r in Request,
            where: r.technician_id == ^user.id and not r.hidden and not is_nil(r.outcome)
          ),
          :count
        ) >= 2

  def costs, do: Repo.all(from c in Cost, order_by: [desc: c.date, desc: c.id])

  def add_cost(user, attrs) do
    admin!(user)
    %Cost{} |> Cost.changeset(attrs) |> Repo.insert()
  end

  def reports(user) do
    admin!(user)
    Repo.all(from r in Report, order_by: [desc: r.id], preload: [:reporter])
  end

  def report(user, type, id, attrs) do
    user = actor!(user)
    target = target!(type, id)

    %Report{reporter_id: user.id, target_type: type, target_id: target.id}
    |> Report.changeset(attrs)
    |> Repo.insert()
  end

  def resolve(user, id, action) do
    admin!(user)
    allow!(action in ["dismissed", "removed"])

    Repo.transaction(fn ->
      report = Repo.get!(Report, id)
      allow!(is_nil(report.resolution))
      target = target!(report.target_type, report.target_id)

      if action == "removed" do
        allow!(not (report.target_type == "profile" and target.id == user.id))
        field = if report.target_type == "profile", do: :banned, else: :hidden
        Repo.update!(change(target, [{field, true}]))
      end

      Repo.update!(change(report, resolution: action))
    end)
  end

  defp target!("profile", id), do: Repo.get!(User, id)
  defp target!("request", id), do: Repo.get!(Request, id)
  defp target!("comment", id), do: Repo.get!(Entry, id)
  defp target!("review", id), do: Repo.get!(Review, id)
  defp target!(_, _), do: raise(Werepair.ForbiddenError)
end
