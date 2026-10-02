defmodule Werepair.Repairs.Review do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reviews" do
    belongs_to :request, Werepair.Repairs.Request
    belongs_to :author, Werepair.Accounts.User
    belongs_to :recipient, Werepair.Accounts.User
    field :stars, :integer
    field :body, :string
    field :hidden, :boolean, default: false
    timestamps(type: :utc_datetime)
  end

  def changeset(review, attrs) do
    review
    |> cast(attrs, [:stars, :body])
    |> validate_required([:stars])
    |> validate_number(:stars, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> validate_length(:body, max: 1000)
    |> unique_constraint([:request_id, :author_id])
  end
end
