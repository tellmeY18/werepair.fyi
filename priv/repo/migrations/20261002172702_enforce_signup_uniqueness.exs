defmodule Werepair.Repo.Migrations.EnforceSignupUniqueness do
  use Ecto.Migration

  def change do
    create unique_index(:participations, [:event_id, :user_id, :kind],
             where: "mentor_id IS NULL",
             name: :participations_without_mentor_unique
           )
  end
end
