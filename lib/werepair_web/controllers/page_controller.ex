defmodule WerepairWeb.PageController do
  use WerepairWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
