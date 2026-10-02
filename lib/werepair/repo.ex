defmodule Werepair.Repo do
  use Ecto.Repo,
    otp_app: :werepair,
    adapter: Ecto.Adapters.SQLite3
end
