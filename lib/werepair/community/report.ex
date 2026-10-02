defmodule Werepair.Community.Report do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reports" do
    belongs_to :reporter, Werepair.Accounts.User
    field :target_type, :string
    field :target_id, :integer
    field :reason, :string
    field :resolution, :string
    timestamps(type: :utc_datetime)
  end

  def changeset(report, attrs) do
    report
    |> cast(attrs, [:reason])
    |> validate_required([:reason])
    |> validate_length(:reason, min: 5, max: 2000)
  end
end
