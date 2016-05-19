defmodule FactsVsEvents.FactRepo do
  alias FactsVsEvents.Fact.User
  alias FactsVsEvents.Repo
  import Ecto.Query, only: [from: 2]

  @default_commit_message [commit_message: ""]

  def create(model, changeset, [commit_message: commit_message] \\ @default_commit_message) do
    last_uuid = Repo.one(from u in model, select: max(u.uuid)) || 0
    changes = %{transaction_id: 1, uuid: last_uuid + 1, fact: "created", at: Ecto.DateTime.utc, commit_message: commit_message, id: nil}
    Ecto.Changeset.change(changeset, changes) |> Repo.insert()
  end

  def update(update_changeset, [commit_message: commit_message] \\ @default_commit_message) do
    changes = %{transaction_id: update_changeset.model.transaction_id + 1, id: nil, fact: "updated", at: Ecto.DateTime.utc, commit_message: commit_message}
    Ecto.Changeset.change(update_changeset, changes) |> Repo.insert()
  end

  def delete(record, [commit_message: commit_message] \\ @default_commit_message) do
    changes = %{transaction_id: record.transaction_id + 1, fact: "deleted", at: Ecto.DateTime.utc, commit_message: commit_message}
    Ecto.Changeset.change(Map.delete(record, :id), changes) |> Repo.insert()
  end

  def get!(model, uuid, [owner_id: owner_id]) do
    Repo.one!(get_query(model, uuid, owner_id))
  end

  def get(model, uuid, [owner_id: owner_id]) do
    Repo.one(get_query(model, uuid, owner_id))
  end

  def all(model, [owner_id: owner_id]) do
    Repo.all(from u in model,  where: u.owner_id == ^owner_id)
    |> Enum.group_by(fn (record) -> record.uuid end)
    |> Enum.map(fn  ({_, grouped_records}) -> grouped_records end)
    |> Enum.map(fn (grouped_records) -> find_with_biggest_transaction_id_from(grouped_records) end)
    |> Enum.filter(fn(record) -> record.fact != "deleted" end)
  end

  def last_transaction_id(model, uuid) do
    Repo.one(from u in model, 
             where: u.uuid == ^uuid, 
             select: max(u.transaction_id)) || 0
  end

  defp find_with_biggest_transaction_id_from(grouped_records) do
    Enum.sort(grouped_records, fn(grouped_records,y) -> grouped_records.transaction_id < y.transaction_id end)
    |> List.last()
  end

  defp get_query(model, uuid, owner_id) do
    from u in model, 
    where: u.uuid == ^uuid 
    and u.transaction_id == ^last_transaction_id(model, uuid)
    and u.owner_id == ^owner_id
    and u.fact != "deleted"
  end
end
