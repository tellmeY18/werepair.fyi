defmodule WerepairWeb.EventController do
  use WerepairWeb, :controller
  import WerepairWeb.Auth, only: [require_user: 2]
  alias Werepair.{Events, Repairs}
  plug :require_user when action not in [:index, :show]
  def index(conn, _), do: render(conn, :index, events: Events.list())

  def new(conn, _) do
    Werepair.Access.admin!(conn.assigns.current_scope)

    render(conn, :new,
      form: Phoenix.Component.to_form(Events.Event.changeset(%Events.Event{}, %{}))
    )
  end

  def create(conn, %{"event" => attrs}) do
    case Events.create(conn.assigns.current_scope, attrs) do
      {:ok, event} ->
        redirect(conn, to: ~p"/events/#{event.id}")

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:new, form: Phoenix.Component.to_form(changeset))
    end
  end

  def show(conn, %{"id" => id}), do: detail(conn, id)

  defp detail(conn, id, errors \\ []) do
    user = conn.assigns.current_scope
    event = Events.get!(id)

    mentors =
      event.participations
      |> Enum.filter(&(&1.kind == "technician" and Werepair.Community.mentor?(&1.user)))
      |> Enum.map(&{&1.user.name, &1.user_id})

    requests =
      if user,
        do:
          Repairs.list("", user.id)
          |> Enum.filter(
            &(&1.requester_id == user.id and &1.status in ["open", "in_talks", "in_progress"])
          ),
        else: []

    render(conn, :show,
      event: event,
      errors: errors,
      mentors: mentors,
      requests: requests,
      form: Phoenix.Component.to_form(%{}, as: :participation),
      summary_form: Phoenix.Component.to_form(%{}, as: :event)
    )
  end

  def join(conn, %{"id" => id, "participation" => attrs}),
    do: respond(conn, id, Events.join(conn.assigns.current_scope, id, attrs))

  def item(conn, %{"id" => id, "request_id" => request_id}),
    do: respond(conn, id, Events.register_item(conn.assigns.current_scope, id, request_id))

  def record(conn, %{"id" => id, "participation_id" => participation_id, "participation" => attrs}),
      do:
        respond(conn, id, Events.record(conn.assigns.current_scope, id, participation_id, attrs))

  def complete(conn, %{"id" => id, "event" => attrs}),
    do: respond(conn, id, Events.complete(conn.assigns.current_scope, id, attrs))

  defp respond(conn, id, {:ok, _}),
    do: conn |> put_flash(:info, "Event updated.") |> redirect(to: ~p"/events/#{id}")

  defp respond(conn, id, {:error, changeset}),
    do:
      conn
      |> put_status(:unprocessable_entity)
      |> detail(id, WerepairWeb.FormErrors.messages(changeset))
end
