defmodule WerepairWeb.RepairController do
  use WerepairWeb, :controller
  import WerepairWeb.Auth, only: [require_user: 2]
  alias Werepair.{Repairs, Repairs.Request}
  plug :require_user when action not in [:index, :show, :photo]

  def index(conn, params),
    do:
      render(conn, :index,
        requests: Repairs.list(params["q"] || ""),
        form: Phoenix.Component.to_form(params)
      )

  def new(conn, _),
    do:
      render(conn, :new,
        form:
          Phoenix.Component.to_form(
            Request.changeset(%Request{area: conn.assigns.current_scope.area}, %{})
          )
      )

  def create(conn, %{"request" => attrs}) do
    case Repairs.create(conn.assigns.current_scope, attrs, attrs["photo"]) do
      {:ok, request} ->
        conn
        |> put_flash(:info, "Request posted. Keep notes as you learn.")
        |> redirect(to: ~p"/requests/#{request.id}")

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:new, form: Phoenix.Component.to_form(changeset))
    end
  end

  def show(conn, %{"id" => id}), do: detail(conn, id)

  defp detail(conn, id, errors \\ []) do
    request = Repairs.get!(id)

    render(conn, :show,
      request: request,
      errors: errors,
      entry_form: Phoenix.Component.to_form(%{}, as: :entry),
      status_form: Phoenix.Component.to_form(%{}, as: :request),
      review_form: Phoenix.Component.to_form(%{}, as: :review),
      reviews: Repairs.public_reviews(request)
    )
  end

  def photo(conn, %{"id" => id}) do
    request = Repairs.get!(id)

    if request.photo do
      conn
      |> put_resp_content_type(request.photo_type)
      |> put_resp_header("x-content-type-options", "nosniff")
      |> send_resp(200, request.photo)
    else
      send_resp(conn, 404, "No photo")
    end
  end

  def entry(conn, %{"id" => id, "kind" => kind, "entry" => attrs}),
    do: respond(conn, id, Repairs.add_entry(conn.assigns.current_scope, id, kind, attrs))

  def choose(conn, %{"id" => id, "technician_id" => tech}),
    do: respond(conn, id, Repairs.choose(conn.assigns.current_scope, id, tech))

  def status(conn, %{"id" => id, "request" => attrs}),
    do: respond(conn, id, Repairs.transition(conn.assigns.current_scope, id, attrs))

  def confirm(conn, %{"id" => id} = params),
    do:
      respond(conn, id, Repairs.confirm(conn.assigns.current_scope, id, params["request"] || %{}))

  def review(conn, %{"id" => id, "review" => attrs}),
    do: respond(conn, id, Repairs.review(conn.assigns.current_scope, id, attrs))

  def journal(conn, %{"id" => id}) do
    request = Repairs.get!(id)

    Werepair.Access.allow!(
      request.requester_id == conn.assigns.current_scope.id and not is_nil(request.outcome)
    )

    render(conn, :journal,
      request: request,
      text: Werepair.Wiki.journal(request),
      form: Phoenix.Component.to_form(%{"wiki_url" => request.wiki_url}, as: :request)
    )
  end

  def wiki(conn, %{"id" => id, "request" => attrs}),
    do: respond(conn, id, Repairs.link_wiki(conn.assigns.current_scope, id, attrs))

  defp respond(conn, id, {:ok, _}),
    do: conn |> put_flash(:info, "Saved.") |> redirect(to: ~p"/requests/#{id}")

  defp respond(conn, id, {:error, changeset}),
    do:
      conn
      |> put_status(:unprocessable_entity)
      |> detail(id, WerepairWeb.FormErrors.messages(changeset))
end
