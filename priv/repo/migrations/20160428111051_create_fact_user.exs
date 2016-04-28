defmodule FactsVsEvents.Repo.Migrations.CreateFactUser do
  use Ecto.Migration

  def change do
    create table(:fact_users) do
      add :name, :string
      add :email, :string
      add :uuid, :integer
      add :transaction_id, :integer
      add :date, :datetime
      add :fact, :string
      add :commit_message, :string

      timestamps
    end

  end
end
