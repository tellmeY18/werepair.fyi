defmodule Werepair.Repairs.Request do
  use Ecto.Schema
  import Ecto.Changeset

  schema "requests" do
    belongs_to :requester, Werepair.Accounts.User
    belongs_to :technician, Werepair.Accounts.User
    belongs_to :event, Werepair.Events.Event
    field :title, :string
    field :description, :string
    field :tried, :string
    field :category, :string, default: "Other"
    field :area, :string
    field :mode, :string, default: "At an event"
    field :status, :string, default: "open"
    field :outcome, :string
    field :outcome_note, :string
    field :confirmed, :boolean, default: false
    field :credit_consent, :boolean, default: false
    field :hidden, :boolean, default: false
    field :photo, :binary, redact: true
    field :photo_type, :string
    field :wiki_url, :string
    field :document_consent, :boolean, virtual: true, default: false
    has_many :entries, Werepair.Repairs.Entry
    has_many :reviews, Werepair.Repairs.Review
    timestamps(type: :utc_datetime)
  end

  def categories, do: ~w(Electronics Appliances Bicycles Furniture Clothing Other)
  def modes, do: ["At an event", "Visit technician", "Home visit", "Help me learn"]

  def changeset(request, attrs) do
    request
    |> cast(attrs, [:title, :description, :tried, :category, :area, :mode, :document_consent])
    |> validate_required([:title, :description, :area, :category, :mode])
    |> validate_length(:title, min: 3, max: 160)
    |> validate_length(:description, max: 5000)
    |> validate_length(:tried, max: 5000)
    |> validate_inclusion(:category, categories())
    |> validate_inclusion(:mode, modes())
    |> validate_acceptance(:document_consent)
  end
end
