# TODO
# - Commands validation
defmodule FactsVsEvents.CreateUserCommandTest do
  use FactsVsEvents.ModelCase
  alias FactsVsEvents.Repo
  alias FactsVsEvents.UserEvent
  alias FactsVsEvents.CreateUserCommand
  alias FactsVsEvents.ChangeUserCommand
  alias FactsVsEvents.DeleteUserCommand
  import Ecto.Query, only: [from: 2]

  test "create user creates UserCreated event" do
    CreateUserCommand.execute(%{name: "a_name", email: "an_email"})
    found_records = Repo.all(from e in UserEvent, where: e.event_type == "UserCreated")
    assert length(found_records) == 1
  end

  test "create user creates event with data" do
    CreateUserCommand.execute(%{name: "a_name", email: "an_email"})
    found_record = Repo.one(from e in UserEvent, where: e.event_type == "UserCreated")
    assert found_record.data["name"] == "a_name"
    assert found_record.data["email"] == "an_email"
  end

  test "change user command creates UserChanged event" do
    ChangeUserCommand.execute(%{name: "a_name"})
    found_records = Repo.all(from e in UserEvent, where: e.event_type == "UserChanged")
    assert length(found_records) == 1
  end

  test "change user creates event with data" do
    ChangeUserCommand.execute(%{name: "a_name", email: "an_email"})
    found_record = Repo.one(from e in UserEvent, where: e.event_type == "UserChanged")
    assert found_record.data["name"] == "a_name"
  end

  test "delete user command creates UserDeleted event" do
    DeleteUserCommand.execute
    found_records = Repo.all(from e in UserEvent, where: e.event_type == "UserDeleted")
    assert length(found_records) == 1
  end
end
