defmodule FactsVsEvents.Repo.Migrations.CreateUserEvents do
  use Ecto.Migration

  def change do
    create table(:user_events) do
      add :uuid, :integer
      add :data, :map
      add :event_type, :string

      timestamps
    end

  end
end
