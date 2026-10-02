defmodule Werepair.Community.Cost do
  use Ecto.Schema
  import Ecto.Changeset

  schema "costs" do
    field :date, :date
    field :description, :string
    field :paid_by, :string
    field :kind, :string, default: "expense"
    field :amount, :decimal
    timestamps(type: :utc_datetime)
  end

  def changeset(cost, attrs) do
    cost
    |> cast(attrs, [:date, :description, :paid_by, :kind, :amount])
    |> validate_required([:date, :description, :paid_by, :kind, :amount])
    |> validate_inclusion(:kind, ["expense", "donation"])
    |> validate_number(:amount, greater_than_or_equal_to: 0)
  end
end
