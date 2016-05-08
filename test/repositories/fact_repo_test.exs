# TODO
# - history of records
# - difference between transactions

defmodule FactsVsEvents.FactRepoTest do
  use FactsVsEvents.ModelCase
  alias FactsVsEvents.FactRepo
  alias FactsVsEvents.FactUser

  test "creation with properties automatically set" do
    changeset = FactUser.changeset(%FactUser{}, %{name: "a_name", email: "an_email", owner_id: 1})
    {:ok, record} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    fact_user = Repo.get!(FactUser, record.id)
    assert length(Repo.all(FactUser)) == 1
    assert fact_user.name == "a_name"
    assert fact_user.email == "an_email"
    assert fact_user.transaction_id == 1
    assert fact_user.uuid == 1
    assert fact_user.owner_id == 1
    assert fact_user.fact == "created"
    assert fact_user.at != nil
    assert fact_user.commit_message == "Create a new user"
  end

  test "creation without commit message" do
    {:ok, record} = FactRepo.create(FactUser, %FactUser{})
    fact_user = Repo.get!(FactUser, record.id)
    assert length(Repo.all(FactUser)) == 1
    assert fact_user.fact == "created"
    assert fact_user.commit_message == ""
  end

  test "multiple creation" do
    {:ok, record} = FactRepo.create(FactUser, %FactUser{}, commit_message: "Create a new user")
    {:ok, record2} = FactRepo.create(FactUser, %FactUser{}, commit_message: "Create a new user")
    fact_user = Repo.get!(FactUser, record.id)
    fact_user2 = Repo.get!(FactUser, record2.id)
    assert length(Repo.all(FactUser)) == 2
    assert fact_user2.uuid == fact_user.uuid + 1
  end

  test "update maintaining the previous record" do
    changeset = FactUser.changeset(%FactUser{}, %{name: "a_name", email: "an_email", owner_id: 1})
    {:ok, record} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    {:ok, update_record} = FactRepo.update(FactUser.changeset(record, %{name: "other"}), commit_message: "Update this")
    assert length(Repo.all(FactUser)) == 2
    assert record.uuid == update_record.uuid
    assert record.transaction_id == update_record.transaction_id - 1
    assert update_record.name == "other"
    assert update_record.owner_id == 1
    assert update_record.fact == "updated"
  end

  test "delete maintainin the previous record" do
    {:ok, record} = FactRepo.create(FactUser, %FactUser{}, commit_message: "Create a new user")
    {:ok, deleted_record} = FactRepo.delete(record, commit_message: "Deleting this")
    assert length(Repo.all(FactUser)) == 2
    assert record.uuid == deleted_record.uuid
    assert record.transaction_id == deleted_record.transaction_id - 1
    assert deleted_record.fact == "deleted"
  end

  test "get! return the last instance" do
    changeset = FactUser.changeset(%FactUser{}, %{name: "a_name", email: "an_email", owner_id: 1})
    {:ok, record} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    update_changeset = FactUser.changeset(record, %{name: "other"})
    FactRepo.update(update_changeset, commit_message: "Update this")
    found_record = FactRepo.get!(FactUser, record.uuid, owner_id: 1)
    assert found_record.name == "other"
  end

  test "get! return the last instance with correct owner id" do
    changeset = FactUser.changeset(%FactUser{}, %{name: "a_name", email: "an_email", owner_id: 1})
    {:ok, record} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    changeset = FactUser.changeset(%FactUser{}, %{name: "a_name2", email: "an_email", owner_id: 2})
    {:ok, record2} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    found_record = FactRepo.get!(FactUser, record.uuid, owner_id: 1)
    assert found_record.name == "a_name"
  end

  test "get doesnt return the last instance when deleted" do
    {:ok, record} = FactRepo.create(FactUser, %FactUser{}, commit_message: "Create a new user")
    FactRepo.delete(record, commit_message: "Deleting this")
    found_record = FactRepo.get(FactUser, record.uuid, owner_id: 1)
    assert found_record == nil
  end

  test "get! doesnt return the last instance when deleted" do
    changeset = FactUser.changeset(%FactUser{}, %{name: "a_name", email: "an_email", owner_id: 1})
    {:ok, record} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    FactRepo.delete(record, commit_message: "Deleting this")
    try do
      found_record = FactRepo.get!(FactUser, record.uuid, owner_id: 1)
      raise "fail"
    rescue
      Ecto.NoResultsError -> assert true == true
    end
  end

  test "all return the last instances" do
    changeset = FactUser.changeset(%FactUser{}, %{name: "a_name", email: "an_email", owner_id: 1})
    {:ok, record} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    update_changeset = FactUser.changeset(record, %{name: "other"})
    FactRepo.update(update_changeset, commit_message: "Update this")
    changeset = FactUser.changeset(%FactUser{}, %{name: "a_name", email: "an_email", owner_id: 1})
    {:ok, record2} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    found_records = FactRepo.all(FactUser, owner_id: 1)
    assert Enum.map(found_records, fn (u) -> u.transaction_id end) == [2, 1]
  end

  test "all return just the owner ones" do
    changeset = FactUser.changeset(%FactUser{}, %{name: "a_name", email: "an_email", owner_id: 1})
    {:ok, record} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    changeset = FactUser.changeset(%FactUser{}, %{name: "a_name", email: "an_email", owner_id: 2})
    {:ok, record2} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    found_records = FactRepo.all(FactUser, owner_id: 2)
    assert Enum.map(found_records, fn (u) -> u.owner_id end) == [2]
    assert length(found_records) == 1
  end

  test "all return no deleted instances" do
    changeset = FactUser.changeset(%FactUser{}, %{name: "a_name", email: "an_email", owner_id: 2})
    {:ok, record} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    FactRepo.delete(record, commit_message: "Deleting this")
    found_records = FactRepo.all(FactUser, owner_id: 2)
    assert length(found_records) == 0
  end
end
