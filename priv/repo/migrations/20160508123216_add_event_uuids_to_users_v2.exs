defmodule FactsVsEvents.Repo.Migrations.AddEventUuidsToUsersV2 do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :event_uuids, {:array, :integer}
    end
  end
end
