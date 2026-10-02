defmodule Werepair.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  @derive {Inspect, except: [:password, :password_hash, :phone, :email]}
  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :password_hash, :string, redact: true
    field :phone, :string
    field :area, :string
    field :bio, :string
    field :skills, :string
    field :availability, :string
    field :latitude, :float
    field :longitude, :float
    field :technician, :boolean, default: false
    field :admin, :boolean, default: false
    field :banned, :boolean, default: false
    field :adult, :boolean, virtual: true, default: false
    timestamps(type: :utc_datetime)
  end

  def profile_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :name,
      :phone,
      :area,
      :bio,
      :skills,
      :availability,
      :latitude,
      :longitude,
      :technician
    ])
    |> validate_required([:name, :phone, :area])
    |> validate_length(:name, min: 2, max: 100)
    |> validate_length(:area, max: 120)
    |> validate_length(:bio, max: 2000)
    |> validate_length(:skills, max: 200)
    |> validate_format(:phone, ~r/^\+?[0-9 ()-]{8,20}$/)
    |> validate_number(:latitude, greater_than_or_equal_to: -90, less_than_or_equal_to: 90)
    |> validate_number(:longitude, greater_than_or_equal_to: -180, less_than_or_equal_to: 180)
  end

  def registration_changeset(user, attrs) do
    user
    |> profile_changeset(attrs)
    |> cast(attrs, [:email, :password, :adult])
    |> update_change(:email, &String.downcase(String.trim(&1)))
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> validate_length(:email, max: 160)
    |> validate_length(:password, min: 12, max: 128)
    |> validate_acceptance(:adult)
    |> unique_constraint(:email)
  end
end
