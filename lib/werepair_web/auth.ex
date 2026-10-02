defmodule WerepairWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller
  def init(opts), do: opts

  def call(conn, _) do
    signed_at = get_session(conn, :signed_at)

    user =
      if is_integer(signed_at) and System.system_time(:second) - signed_at < 604_800,
        do: Werepair.Accounts.current_user(get_session(conn, :user_id))

    assign(conn, :current_scope, user)
  end

  def require_user(conn, _) do
    if conn.assigns.current_scope,
      do: conn,
      else:
        conn
        |> put_flash(:error, "Please sign in to continue.")
        |> redirect(to: "/sign-in")
        |> halt()
  end

  def sign_in(conn, user) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
    |> put_session(:user_id, user.id)
    |> put_session(:signed_at, System.system_time(:second))
  end
end
