# TODO
# - history of records
# - difference between transactions

defmodule FactsVsEvents.FactRepoTest do
  use FactsVsEvents.ModelCase
  alias FactsVsEvents.FactRepo
  alias FactsVsEvents.Fact.User

  test "creation with properties automatically set" do
    changeset = User.changeset(%User{}, %{name: "a_name", email: "an_email", owner_id: 1})
    {:ok, record} = FactRepo.create(User, changeset, commit_message: "Create a new user")
    fact_user = Repo.get!(User, record.id)
    assert length(Repo.all(User)) == 1
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
    {:ok, record} = FactRepo.create(User, %User{})
    fact_user = Repo.get!(User, record.id)
    assert length(Repo.all(User)) == 1
    assert fact_user.fact == "created"
    assert fact_user.commit_message == ""
  end

  test "multiple creation" do
    {:ok, record} = FactRepo.create(User, %User{}, commit_message: "Create a new user")
    {:ok, record2} = FactRepo.create(User, %User{}, commit_message: "Create a new user")
    fact_user = Repo.get!(User, record.id)
    fact_user2 = Repo.get!(User, record2.id)
    assert length(Repo.all(User)) == 2
    assert fact_user2.uuid == fact_user.uuid + 1
  end

  test "update maintaining the previous record" do
    changeset = User.changeset(%User{}, %{name: "a_name", email: "an_email", owner_id: 1})
    {:ok, record} = FactRepo.create(User, changeset, commit_message: "Create a new user")
    {:ok, update_record} = FactRepo.update(User.changeset(record, %{name: "other"}), commit_message: "Update this")
    assert length(Repo.all(User)) == 2
    assert record.uuid == update_record.uuid
    assert record.transaction_id == update_record.transaction_id - 1
    assert update_record.name == "other"
    assert update_record.owner_id == 1
    assert update_record.fact == "updated"
  end

  test "delete maintainin the previous record" do
    {:ok, record} = FactRepo.create(User, %User{}, commit_message: "Create a new user")
    {:ok, deleted_record} = FactRepo.delete(record, commit_message: "Deleting this")
    assert length(Repo.all(User)) == 2
    assert record.uuid == deleted_record.uuid
    assert record.transaction_id == deleted_record.transaction_id - 1
    assert deleted_record.fact == "deleted"
  end

  test "get! return the last instance" do
    changeset = User.changeset(%User{}, %{name: "a_name", email: "an_email", owner_id: 1})
    {:ok, record} = FactRepo.create(User, changeset, commit_message: "Create a new user")
    update_changeset = User.changeset(record, %{name: "other"})
    FactRepo.update(update_changeset, commit_message: "Update this")
    found_record = FactRepo.get!(User, record.uuid, owner_id: 1)
    assert found_record.name == "other"
  end

  test "get! return the last instance with correct owner id" do
    changeset = User.changeset(%User{}, %{name: "a_name", email: "an_email", owner_id: 1})
    {:ok, record} = FactRepo.create(User, changeset, commit_message: "Create a new user")
    changeset = User.changeset(%User{}, %{name: "a_name2", email: "an_email", owner_id: 2})
    {:ok, record2} = FactRepo.create(User, changeset, commit_message: "Create a new user")
    found_record = FactRepo.get!(User, record.uuid, owner_id: 1)
    assert found_record.name == "a_name"
  end

  test "get doesnt return the last instance when deleted" do
    {:ok, record} = FactRepo.create(User, %User{}, commit_message: "Create a new user")
    FactRepo.delete(record, commit_message: "Deleting this")
    found_record = FactRepo.get(User, record.uuid, owner_id: 1)
    assert found_record == nil
  end

  test "get! doesnt return the last instance when deleted" do
    changeset = User.changeset(%User{}, %{name: "a_name", email: "an_email", owner_id: 1})
    {:ok, record} = FactRepo.create(User, changeset, commit_message: "Create a new user")
    FactRepo.delete(record, commit_message: "Deleting this")
    try do
      found_record = FactRepo.get!(User, record.uuid, owner_id: 1)
      raise "fail"
    rescue
      Ecto.NoResultsError -> assert true == true
    end
  end

  test "all return the last instances" do
    changeset = User.changeset(%User{}, %{name: "a_name", email: "an_email", owner_id: 1})
    {:ok, record} = FactRepo.create(User, changeset, commit_message: "Create a new user")
    update_changeset = User.changeset(record, %{name: "other"})
    FactRepo.update(update_changeset, commit_message: "Update this")
    changeset = User.changeset(%User{}, %{name: "a_name", email: "an_email", owner_id: 1})
    {:ok, record2} = FactRepo.create(User, changeset, commit_message: "Create a new user")
    found_records = FactRepo.all(User, owner_id: 1)
    assert Enum.map(found_records, fn (u) -> u.transaction_id end) == [2, 1]
  end

  test "all return just the owner ones" do
    changeset = User.changeset(%User{}, %{name: "a_name", email: "an_email", owner_id: 1})
    {:ok, record} = FactRepo.create(User, changeset, commit_message: "Create a new user")
    changeset = User.changeset(%User{}, %{name: "a_name", email: "an_email", owner_id: 2})
    {:ok, record2} = FactRepo.create(User, changeset, commit_message: "Create a new user")
    found_records = FactRepo.all(User, owner_id: 2)
    assert Enum.map(found_records, fn (u) -> u.owner_id end) == [2]
    assert length(found_records) == 1
  end

  test "all return no deleted instances" do
    changeset = User.changeset(%User{}, %{name: "a_name", email: "an_email", owner_id: 2})
    {:ok, record} = FactRepo.create(User, changeset, commit_message: "Create a new user")
    FactRepo.delete(record, commit_message: "Deleting this")
    found_records = FactRepo.all(User, owner_id: 2)
    assert length(found_records) == 0
  end
end
