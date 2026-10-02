defmodule Werepair.Events do
  import Ecto.Query
  import Ecto.Changeset
  import Werepair.Access
  alias Werepair.{Repo, Community}
  alias Werepair.Events.{Event, Participation}

  def list,
    do: Repo.all(from e in Event, order_by: [asc: e.completed, asc: e.starts_at], limit: 100)

  def get!(id),
    do:
      Repo.get!(Event, id)
      |> Repo.preload([
        :organizer,
        participations: [:user, :mentor],
        requests: from(r in Werepair.Repairs.Request, where: not r.hidden)
      ])

  def create(user, attrs) do
    user = admin!(user)
    %Event{organizer_id: user.id} |> Event.changeset(attrs) |> Repo.insert()
  end

  def join(user, id, attrs) do
    user = actor!(user)
    event = get!(id)
    allow!(not event.completed)
    kind = attrs["kind"]
    allow!(kind in ["technician", "apprentice", "requester"])

    mentor =
      if kind == "apprentice" do
        Enum.find_value(event.participations, fn p ->
          if p.kind == "technician" and to_string(p.user_id) == to_string(attrs["mentor_id"]),
            do: p.user
        end)
      end

    if kind == "technician", do: allow!(user.technician)

    if mentor do
      allow!(mentor.id != user.id and Community.mentor?(mentor))

      allow!(
        Enum.any?(
          event.participations,
          &(&1.user_id == mentor.id and &1.kind == "technician" and &1.status != "no_show")
        )
      )
    end

    mentor_id = mentor && mentor.id

    duplicate =
      Enum.any?(
        event.participations,
        &(&1.user_id == user.id and &1.kind == kind and &1.mentor_id == mentor_id)
      )

    changeset =
      Participation.changeset(
        %Participation{
          event_id: event.id,
          user_id: user.id,
          mentor_id: mentor_id,
          kind: kind,
          status: if(mentor, do: "pending", else: "registered")
        },
        attrs
      )

    changeset =
      if duplicate,
        do: add_error(changeset, :note, "you already signed up for this"),
        else: changeset

    changeset =
      if kind == "apprentice" and is_nil(mentor),
        do: add_error(changeset, :note, "select an attending mentor"),
        else: changeset

    Repo.insert(changeset)
  end

  def record(user, event_id, participation_id, attrs) do
    user = actor!(user)
    event = get!(event_id)
    participation = Repo.get_by!(Participation, id: participation_id, event_id: event.id)
    mentor? = participation.kind == "apprentice"

    allow!(
      if mentor?, do: participation.mentor_id == user.id, else: user.id == event.organizer_id
    )

    statuses =
      if mentor?,
        do: ["accepted", "declined", "attended", "no_show"],
        else: ["attended", "no_show"]

    changeset =
      participation
      |> cast(attrs, [:status, :hours])
      |> validate_inclusion(:status, statuses)
      |> validate_number(:hours, greater_than_or_equal_to: 0, less_than_or_equal_to: 24)

    changeset =
      cond do
        get_field(changeset, :status) != "attended" ->
          put_change(changeset, :hours, 0)

        mentor? and (get_field(changeset, :hours) || 0) <= 0 ->
          add_error(changeset, :hours, "must be greater than zero for attendance")

        not mentor? ->
          put_change(changeset, :hours, 0)

        true ->
          changeset
      end

    Repo.update(changeset)
  end

  def register_item(user, id, request_id) do
    user = actor!(user)
    event = get!(id)
    request = Werepair.Repairs.get!(request_id)

    allow!(
      not event.completed and request.requester_id == user.id and
        request.status in ["open", "in_talks", "in_progress"]
    )

    Repo.update(change(request, event_id: event.id, mode: "At an event"))
  end

  def complete(user, id, attrs) do
    event = get!(id)
    allow!(actor!(user).id == event.organizer_id)

    event
    |> cast(attrs, [:summary])
    |> validate_required([:summary])
    |> validate_length(:summary, max: 5000)
    |> put_change(:completed, true)
    |> Repo.update()
  end
end
