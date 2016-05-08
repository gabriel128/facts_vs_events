defmodule FactsVsEvents.Repo.Migrations.AddOwnerIdToFactUsers do
  use Ecto.Migration

  def change do
    alter table(:fact_users) do
      add :owner_id, :integer
    end
  end
end
