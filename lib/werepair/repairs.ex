defmodule Werepair.Repairs do
  import Ecto.Query
  import Ecto.Changeset
  import Werepair.Access
  alias Werepair.{Repo, Accounts, Notifications}
  alias Werepair.Repairs.{Request, Entry, Review}

  def list(query \\ "", user_id \\ nil) do
    term = "%#{query}%"

    query =
      from r in Request,
        where:
          not r.hidden and
            (like(r.title, ^term) or like(r.area, ^term) or like(r.category, ^term)),
        order_by: [desc: r.id],
        limit: 100

    query =
      if user_id,
        do: from(r in query, where: r.requester_id == ^user_id or r.technician_id == ^user_id),
        else: query

    Repo.all(query) |> Repo.preload([:requester, :technician])
  end

  def get!(id) do
    Repo.one!(from r in Request, where: r.id == ^id and not r.hidden)
    |> Repo.preload([
      :requester,
      :technician,
      :event,
      entries: {from(e in Entry, where: not e.hidden, order_by: e.id), :user},
      reviews: :author
    ])
  end

  def create(user, attrs, upload \\ nil) do
    user = actor!(user)
    Request.changeset(%Request{requester_id: user.id}, attrs) |> photo(upload) |> Repo.insert()
  end

  # ponytail: one <=2 MB image in SQLite per request; move to object storage at public scale.
  defp photo(changeset, nil), do: changeset

  defp photo(changeset, %Plug.Upload{path: path}) do
    case File.stat(path) do
      {:ok, %{size: size}} when size <= 2_000_000 ->
        bytes = File.read!(path)

        type =
          case bytes do
            <<0xFF, 0xD8, 0xFF, _::binary>> -> "image/jpeg"
            <<137, 80, 78, 71, 13, 10, 26, 10, _::binary>> -> "image/png"
            _ -> nil
          end

        if type,
          do: change(changeset, photo: bytes, photo_type: type),
          else: add_error(changeset, :description, "photo must be PNG or JPEG")

      _ ->
        add_error(changeset, :description, "photo must be smaller than 2 MB")
    end
  end

  defp photo(changeset, _), do: add_error(changeset, :description, "invalid photo")

  def add_entry(user, id, kind, attrs) do
    user = actor!(user)
    request = get!(id)
    allow!(kind in ["comment", "log"])
    allow!(kind == "comment" or request.requester_id == user.id)
    allow!(request.status not in ["cancelled", "closed"])

    result =
      Repo.transaction(fn ->
        entry =
          %Entry{request_id: request.id, user_id: user.id, kind: kind}
          |> Entry.changeset(attrs)
          |> insert_or_rollback()

        if kind == "comment" and request.status == "open" and user.id != request.requester_id,
          do: Repo.update!(change(request, status: "in_talks"))

        entry
      end)

    if match?({:ok, _}, result),
      do: Notifications.send(request.requester, "New repair #{kind}", "/requests/#{id}")

    result
  end

  def choose(user, id, technician_id) do
    user = actor!(user)

    Repo.transaction(fn ->
      request = get!(id)
      tech = Accounts.get_user!(technician_id)
      allow!(request.requester_id == user.id and request.status in ["open", "in_talks"])
      allow!(tech.technician and not tech.banned and tech.id != user.id)

      allow!(
        Repo.exists?(
          from e in Entry,
            where:
              e.request_id == ^request.id and e.user_id == ^tech.id and e.kind == "comment" and
                not e.hidden
        )
      )

      Repo.update!(change(request, technician_id: tech.id, status: "in_progress"))
    end)
  end

  def transition(user, id, attrs) do
    user = actor!(user)

    Repo.transaction(fn ->
      request = get!(id)
      allow!(request.requester_id == user.id)
      status = attrs["status"]

      allowed =
        case request.status do
          s when s in ["open", "in_talks"] -> ["cancelled"]
          "in_progress" -> ["fixed", "partly", "not_fixed", "open", "cancelled"]
          s when s in ["fixed", "partly", "not_fixed"] -> ["closed"]
          _ -> []
        end

      allow!(status in allowed)

      changeset =
        request
        |> cast(attrs, [:outcome_note])
        |> validate_required([:outcome_note])
        |> validate_length(:outcome_note, max: 5000)
        |> put_change(:status, status)

      changeset =
        cond do
          status in ["fixed", "partly", "not_fixed"] ->
            put_change(changeset, :outcome, status)

          status == "open" ->
            change(changeset, technician_id: nil, confirmed: false, credit_consent: false)

          true ->
            changeset
        end

      updated = update_or_rollback(changeset)

      Repo.insert!(%Entry{
        request_id: request.id,
        user_id: user.id,
        kind: "status",
        body: "#{status}: #{updated.outcome_note}"
      })

      updated
    end)
  end

  def confirm(user, id, attrs) do
    user = actor!(user)
    request = get!(id)
    allow!(request.technician_id == user.id and not is_nil(request.outcome))
    request |> cast(attrs, [:credit_consent]) |> put_change(:confirmed, true) |> Repo.update()
  end

  def review(user, id, attrs) do
    user = actor!(user)
    request = get!(id)

    allow!(
      request.status == "closed" and user.id in [request.requester_id, request.technician_id]
    )

    recipient =
      if user.id == request.requester_id, do: request.technician_id, else: request.requester_id

    allow!(not is_nil(recipient) and recipient != user.id)

    %Review{request_id: request.id, author_id: user.id, recipient_id: recipient}
    |> Review.changeset(attrs)
    |> Repo.insert()
  end

  def public_reviews(request),
    do: if(length(request.reviews) == 2, do: Enum.reject(request.reviews, & &1.hidden), else: [])

  def link_wiki(user, id, attrs) do
    request = get!(id)
    allow!(actor!(user).id == request.requester_id and not is_nil(request.outcome))
    base = Werepair.Wiki.base_url()

    changeset =
      request
      |> cast(attrs, [:wiki_url])
      |> validate_required([:wiki_url])
      |> validate_change(:wiki_url, fn :wiki_url, url ->
        if String.starts_with?(url, base <> "/"),
          do: [],
          else: [wiki_url: "must point to the configured repair wiki"]
      end)

    Repo.update(changeset)
  end

  defp insert_or_rollback(changeset) do
    case Repo.insert(changeset) do
      {:ok, record} -> record
      {:error, error} -> Repo.rollback(error)
    end
  end

  defp update_or_rollback(changeset) do
    case Repo.update(changeset) do
      {:ok, record} -> record
      {:error, error} -> Repo.rollback(error)
    end
  end
end
