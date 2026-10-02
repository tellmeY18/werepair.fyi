defmodule Werepair.Repairs.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "entries" do
    belongs_to :request, Werepair.Repairs.Request
    belongs_to :user, Werepair.Accounts.User
    field :kind, :string
    field :body, :string
    field :parts, :string
    field :purchased_by, :string
    field :price, :decimal
    field :hidden, :boolean, default: false
    timestamps(type: :utc_datetime)
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:body, :parts, :purchased_by, :price])
    |> validate_required([:body])
    |> validate_length(:body, max: 5000)
    |> validate_number(:price, greater_than_or_equal_to: 0, less_than_or_equal_to: 10_000_000)
  end
end
