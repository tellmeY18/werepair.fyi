defmodule WerepairWeb.HealthController do
  use WerepairWeb, :controller

  def show(conn, _) do
    Ecto.Adapters.SQL.query!(Werepair.Repo, "SELECT 1", [])
    json(conn, %{status: "ok"})
  end
end
