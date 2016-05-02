defmodule FactsVsEvents.Repo.Migrations.CreateEventUser do
  use Ecto.Migration

  def change do
    create table(:event_users) do
      add :name, :string
      add :email, :string

      timestamps
    end

  end
end
