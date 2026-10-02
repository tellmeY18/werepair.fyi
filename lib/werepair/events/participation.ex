defmodule Werepair.Events.Participation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "participations" do
    belongs_to :event, Werepair.Events.Event
    belongs_to :user, Werepair.Accounts.User
    belongs_to :mentor, Werepair.Accounts.User
    field :kind, :string
    field :note, :string
    field :status, :string
    field :hours, :integer, default: 0
    field :consent, :boolean, virtual: true, default: false
    timestamps(type: :utc_datetime)
  end

  def changeset(participation, attrs) do
    participation
    |> cast(attrs, [:note, :consent])
    |> validate_required([:note])
    |> validate_length(:note, max: 1000)
    |> validate_acceptance(:consent)
    |> unique_constraint([:event_id, :user_id, :kind, :mentor_id])
    |> unique_constraint(:note, name: :participations_without_mentor_unique)
  end
end
