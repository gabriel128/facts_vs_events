# TODO
defmodule FactsVsEvents.UserStateHandlerTest do
  use FactsVsEvents.ModelCase
  alias FactsVsEvents.CreateUserCommand
  alias FactsVsEvents.ChangeUserCommand
  alias FactsVsEvents.DeleteUserCommand
  alias FactsVsEvents.UserStateHandler
  alias FactsVsEvents.EventUser
  alias FactsVsEvents.UserEvent
  alias FactsVsEvents.UserEventRepo
  import Ecto.Query, only: [from: 2]

  test "reconstruct state from just created object" do
    CreateUserCommand.execute(%{name: "a_name", email: "an_email"})
    user = UserEventRepo.find(uuid: 1, with: UserStateHandler)
    assert user.name == "a_name"
    assert user.email == "an_email"
    assert user.uuid == 1
  end

  test "after creation and changes User has the right state" do
    CreateUserCommand.execute(%{name: "a_name", email: "an_email"})
    last_uuid = Repo.one(from u in UserEvent, select: max(u.uuid))
    ChangeUserCommand.execute(last_uuid, %{name: "other_name"})
    ChangeUserCommand.execute(last_uuid, %{name: "another_name"})
    user = UserEventRepo.find(uuid: last_uuid, with: UserStateHandler)
    assert user.name == "another_name"
    assert user.email == "an_email"
  end

  test "after delete User is empty" do
    CreateUserCommand.execute(%{name: "a_name", email: "an_email"})
    ChangeUserCommand.execute(1, %{name: "other_name"})
    DeleteUserCommand.execute(1)
    user = UserEventRepo.find(uuid: 1, with: UserStateHandler)
    assert user == %{}
  end

  test "construct all the users" do
    CreateUserCommand.execute(%{name: "a_name", email: "an_email"})
    CreateUserCommand.execute(%{name: "b_name", email: "an_email"})
    users = UserEventRepo.uuids
           |> UserStateHandler.all(with_repo: UserEventRepo)
    assert Enum.at(users, 0).name == "a_name"
    assert Enum.at(users, 1).name == "b_name"
  end

  test "construct all the users without the deleted one" do
    CreateUserCommand.execute(%{name: "a_name", email: "an_email"})
    CreateUserCommand.execute(%{name: "b_name", email: "an_email"})
    DeleteUserCommand.execute(2)
    users = UserEventRepo.uuids
           |> UserStateHandler.all(with_repo: UserEventRepo)
    assert length(users) == 1
  end
end
