defmodule WerepairWeb.SessionController do
  use WerepairWeb, :controller
  alias Werepair.{Accounts, Accounts.User}
  def new(conn, _), do: render(conn, :new, form: Phoenix.Component.to_form(%{}, as: :session))

  def create(conn, %{"session" => attrs}) do
    case Accounts.authenticate(attrs["email"] || "", attrs["password"] || "") do
      {:ok, user} ->
        conn |> WerepairWeb.Auth.sign_in(user) |> redirect(to: ~p"/profile")

      {:error, _} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_flash(:error, "Email or password is incorrect, or the account is suspended.")
        |> new(%{})
    end
  end

  def delete(conn, _), do: conn |> configure_session(drop: true) |> redirect(to: ~p"/")

  def register(conn, _),
    do:
      render(conn, :register,
        form: Phoenix.Component.to_form(User.registration_changeset(%User{}, %{}))
      )

  def save(conn, %{"user" => attrs}) do
    case Accounts.register(attrs) do
      {:ok, user} ->
        conn |> WerepairWeb.Auth.sign_in(user) |> redirect(to: ~p"/profile")

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:register, form: Phoenix.Component.to_form(changeset))
    end
  end
end
