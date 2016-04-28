defmodule FactsVsEvents.Repo.Migrations.ModifyFactUserDate do
  use Ecto.Migration

  def up do
    alter table(:fact_users) do
      add :at, :datetime
      remove :date
      remove :inserted_at
      remove :updated_at
    end
  end

  def down do
    alter table(:fact_users) do
      add :date, :datetime
      remove :at
      timestamps
    end
  end
end
