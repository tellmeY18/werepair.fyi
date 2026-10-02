defmodule Werepair.Repo.Migrations.CreatePlatform do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :phone, :string, null: false
      add :area, :string, null: false
      add :bio, :text
      add :skills, :string
      add :availability, :string
      add :latitude, :float
      add :longitude, :float
      add :technician, :boolean, default: false, null: false
      add :admin, :boolean, default: false, null: false
      add :banned, :boolean, default: false, null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])

    create table(:events) do
      add :organizer_id, references(:users), null: false
      add :title, :string, null: false
      add :theme, :string, null: false
      add :venue, :string, null: false
      add :starts_at, :naive_datetime, null: false
      add :latitude, :float, null: false
      add :longitude, :float, null: false
      add :rules, :text, null: false
      add :summary, :text
      add :completed, :boolean, default: false, null: false
      timestamps(type: :utc_datetime)
    end

    create table(:requests) do
      add :requester_id, references(:users), null: false
      add :technician_id, references(:users)
      add :event_id, references(:events)
      add :title, :string, null: false
      add :description, :text, null: false
      add :tried, :text
      add :category, :string, null: false
      add :area, :string, null: false
      add :mode, :string, null: false
      add :status, :string, default: "open", null: false
      add :outcome, :string
      add :outcome_note, :text
      add :confirmed, :boolean, default: false, null: false
      add :credit_consent, :boolean, default: false, null: false
      add :hidden, :boolean, default: false, null: false
      add :photo, :binary
      add :photo_type, :string
      add :wiki_url, :string
      timestamps(type: :utc_datetime)
    end

    create index(:requests, [:requester_id])
    create index(:requests, [:technician_id])

    create table(:entries) do
      add :request_id, references(:requests), null: false
      add :user_id, references(:users), null: false
      add :kind, :string, null: false
      add :body, :text, null: false
      add :parts, :string
      add :purchased_by, :string
      add :price, :decimal
      add :hidden, :boolean, default: false, null: false
      timestamps(type: :utc_datetime)
    end

    create index(:entries, [:request_id])

    create table(:reviews) do
      add :request_id, references(:requests), null: false
      add :author_id, references(:users), null: false
      add :recipient_id, references(:users), null: false
      add :stars, :integer, null: false
      add :body, :string
      add :hidden, :boolean, default: false, null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:reviews, [:request_id, :author_id])

    create table(:participations) do
      add :event_id, references(:events), null: false
      add :user_id, references(:users), null: false
      add :mentor_id, references(:users)
      add :kind, :string, null: false
      add :note, :string, null: false
      add :status, :string, null: false
      add :hours, :integer, default: 0, null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:participations, [:event_id, :user_id, :kind, :mentor_id])

    create table(:reports) do
      add :reporter_id, references(:users), null: false
      add :target_type, :string, null: false
      add :target_id, :integer, null: false
      add :reason, :text, null: false
      add :resolution, :string
      timestamps(type: :utc_datetime)
    end

    create table(:costs) do
      add :date, :date, null: false
      add :description, :string, null: false
      add :paid_by, :string, null: false
      add :kind, :string, null: false
      add :amount, :decimal, null: false
      timestamps(type: :utc_datetime)
    end
  end
end
