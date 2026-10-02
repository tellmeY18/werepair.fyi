defmodule Werepair.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    belongs_to :organizer, Werepair.Accounts.User
    field :title, :string
    field :theme, :string
    field :venue, :string
    field :starts_at, :naive_datetime
    field :latitude, :float, default: 9.9816
    field :longitude, :float, default: 76.2999

    field :rules, :string,
      default:
        "Owners stay with their items. No live electrical work by learners. Bring only items you own. Take all items and replaced parts home. Organiser checks venue permission, power and fire safety."

    field :summary, :string
    field :completed, :boolean, default: false
    has_many :participations, Werepair.Events.Participation
    has_many :requests, Werepair.Repairs.Request
    timestamps(type: :utc_datetime)
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:title, :theme, :venue, :starts_at, :latitude, :longitude, :rules])
    |> validate_required([:title, :theme, :venue, :starts_at, :latitude, :longitude, :rules])
    |> validate_length(:title, max: 160)
    |> validate_number(:latitude, greater_than_or_equal_to: -90, less_than_or_equal_to: 90)
    |> validate_number(:longitude, greater_than_or_equal_to: -180, less_than_or_equal_to: 180)
  end
end
