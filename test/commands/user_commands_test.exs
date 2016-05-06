# TODO
# - Create Command should have name and email validation
# - Change Command should search if Create one is already there validation
defmodule FactsVsEvents.CreateUserCommandTest do
  use FactsVsEvents.ModelCase
  alias FactsVsEvents.Repo
  alias FactsVsEvents.UserEvent
  alias FactsVsEvents.CreateUserCommand
  alias FactsVsEvents.ChangeUserCommand
  alias FactsVsEvents.DeleteUserCommand
  import Ecto.Query, only: [from: 2]

  test "create user creates UserCreated event" do
    {:ok} = CreateUserCommand.execute(%{name: "a_name", email: "an_email"})
    found_records = Repo.all(from e in UserEvent, where: e.event_type == "UserCreated")
    assert length(found_records) == 1
  end

  test "create user generates uuid" do
    {:ok} = CreateUserCommand.execute(%{name: "a_name", email: "an_email"})
    {:ok} = CreateUserCommand.execute(%{name: "a_name", email: "an_email"})
    found_records = Repo.all(from e in UserEvent, where: e.event_type == "UserCreated")
    found_record = List.last found_records
    assert found_record.uuid == 2
  end

  test "create user generates uuid + 1 when record exists" do
    {:ok} = CreateUserCommand.execute(%{name: "a_name", email: "an_email"})
    found_record = Repo.one(from e in UserEvent, where: e.event_type == "UserCreated")
    assert found_record.uuid == 1
  end

  test "create user creates event with data" do
    CreateUserCommand.execute(%{name: "a_name", email: "an_email"})
    found_record = Repo.one(from e in UserEvent, where: e.event_type == "UserCreated")
    assert found_record.data["name"] == "a_name"
    assert found_record.data["email"] == "an_email"
  end

  test "change user command creates UserChanged event" do
    {:ok} = ChangeUserCommand.execute(2, %{name: "a_name"})
    found_records = Repo.all(from e in UserEvent, where: e.event_type == "UserChanged")
    assert length(found_records) == 1
  end

  test "change user creates event with data" do
    ChangeUserCommand.execute(2, %{name: "a_name", email: "an_email"})
    found_record = Repo.one(from e in UserEvent, where: e.event_type == "UserChanged")
    assert found_record.data["name"] == "a_name"
  end

  test "change user creates just new data" do
    CreateUserCommand.execute(%{name: "a_name", email: "an_email"})
    ChangeUserCommand.execute(1, %{name: "other_name", email: "an_email"})
    found_record = Repo.one(from e in UserEvent, where: e.event_type == "UserChanged")
    assert found_record.data == %{ "name" => "other_name"}
  end

  test "delete user command creates UserDeleted event" do
    {:ok} = DeleteUserCommand.execute(2)
    found_records = Repo.all(from e in UserEvent, where: e.event_type == "UserDeleted")
    assert length(found_records) == 1
  end

  test "create user with invalid email fails with error" do
    response = CreateUserCommand.execute(%{name: "a_name"})
    assert response == {:error, "Missing email"}
  end

  test "create user with invalid name fails with error" do
    response = CreateUserCommand.execute(%{email: "an_email"})
    assert response == {:error, "Missing name"}
  end
end
