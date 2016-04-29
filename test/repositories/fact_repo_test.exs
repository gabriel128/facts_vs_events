defmodule FactsVsEvents.FactRepo do
  alias FactsVsEvents.FactUser
  alias FactsVsEvents.Repo
  import Ecto.Query, only: [from: 2]

  def create(model, changeset, [commit_message: commit_message]) do
    last_uuid = Repo.one(from u in model, select: max(u.uuid)) || 0
    changes = %{transaction_id: 1, uuid: last_uuid + 1, fact: "created", at: Ecto.DateTime.utc, commit_message: commit_message, id: nil}
    Ecto.Changeset.change(changeset, changes) |> Repo.insert()
  end

  def update(record, changes, [commit_message: commit_message]) do
    changes = Map.merge %{transaction_id: record.transaction_id + 1, fact: "updated", at: Ecto.DateTime.utc, commit_message: commit_message}, changes
    Ecto.Changeset.change(Map.delete(record, :id), changes) |> Repo.insert()
  end

  def delete(record, [commit_message: commit_message]) do
    changes = %{transaction_id: record.transaction_id + 1, fact: "deleted", at: Ecto.DateTime.utc, commit_message: commit_message}
    Ecto.Changeset.change(Map.delete(record, :id), changes) |> Repo.insert()
  end

  def get!(model, uuid) do
    last_transaction_id = Repo.one(from u in model, where: u.uuid == ^uuid, select: max(u.transaction_id))
    Repo.one!(from u in model, where: u.uuid == ^uuid and u.transaction_id == ^last_transaction_id)
  end

  def all(model) do
    Repo.all(model)
    |> Enum.group_by(fn (record) -> record.uuid end)
    |> Enum.map(fn  ({_, grouped_records}) -> grouped_records end)
    |> Enum.map(fn (grouped_records) -> get_the_one_with_biggest_transaction_id_from(grouped_records) end)
  end

  defp get_the_one_with_biggest_transaction_id_from(grouped_records) do
    Enum.sort(grouped_records, fn(grouped_records,y) -> grouped_records.transaction_id < y.transaction_id end)
    |> List.last()
  end
end

# TODO
# - multiple creation
# - history of records
# - difference between transactions
# - commit default messessage


defmodule FactsVsEvents.FactRepoTest do
  use FactsVsEvents.ModelCase
  alias FactsVsEvents.FactRepo
  alias FactsVsEvents.FactUser

  test "creation with properties automatically set" do
    changeset = FactUser.changeset(%FactUser{}, %{name: "a_name", email: "an_email"})
    {:ok, record} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    fact_user = Repo.get!(FactUser, record.id)
    assert length(Repo.all(FactUser)) == 1
    assert fact_user.name == "a_name"
    assert fact_user.email == "an_email"
    assert fact_user.transaction_id == 1
    assert fact_user.uuid == 1
    assert fact_user.fact == "created"
    assert fact_user.at != nil
    assert fact_user.commit_message == "Create a new user"
  end

  test "multiple creation" do
    changeset = FactUser.changeset(%FactUser{}, %{name: "a_name", email: "an_email"})
    {:ok, record} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    {:ok, record2} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    fact_user = Repo.get!(FactUser, record.id)
    fact_user2 = Repo.get!(FactUser, record2.id)
    assert length(Repo.all(FactUser)) == 2
    assert fact_user2.uuid == fact_user.uuid + 1
  end

  test "update maintainin the previous record" do
    changeset = FactUser.changeset(%FactUser{}, %{name: "a_name", email: "an_email"})
    {:ok, record} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    {:ok, update_record} = FactRepo.update(record, %{name: "other"}, commit_message: "Update this")
    assert length(Repo.all(FactUser)) == 2
    assert record.uuid == update_record.uuid
    assert record.transaction_id == update_record.transaction_id - 1
    assert update_record.fact == "updated"
  end

  test "delete maintainin the previous record" do
    changeset = FactUser.changeset(%FactUser{}, %{name: "a_name", email: "an_email"})
    {:ok, record} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    {:ok, deleted_record} = FactRepo.delete(record, commit_message: "Deleting this")
    assert length(Repo.all(FactUser)) == 2
    assert record.uuid == deleted_record.uuid
    assert record.transaction_id == deleted_record.transaction_id - 1
    assert deleted_record.fact == "deleted"
  end

  test "find return the last instance" do
    changeset = FactUser.changeset(%FactUser{}, %{name: "a_name", email: "an_email"})
    {:ok, record} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    FactRepo.update(record, %{name: "other"}, commit_message: "Update this")
    found_record = FactRepo.get!(FactUser, record.uuid)
    assert found_record.name == "other"
  end

  test "all return the last instances" do
    changeset = FactUser.changeset(%FactUser{}, %{name: "a_name", email: "an_email"})
    {:ok, record} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    FactRepo.update(record, %{name: "other"}, commit_message: "Update this")
    changeset = FactUser.changeset(%FactUser{}, %{name: "a_name", email: "an_email"})
    {:ok, record2} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    found_records = FactRepo.all(FactUser)
    assert Enum.map(found_records, fn (u) -> u.transaction_id end) == [2, 1]
  end
end
