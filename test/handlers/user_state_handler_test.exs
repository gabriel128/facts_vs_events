# TODO
# - Get all the users
defmodule FactsVsEvents.UserStateHandlerTest do
  use FactsVsEvents.ModelCase
  alias FactsVsEvents.CreateUserCommand
  alias FactsVsEvents.ChangeUserCommand
  alias FactsVsEvents.DeleteUserCommand
  alias FactsVsEvents.UserStateHandler
  alias FactsVsEvents.EventUser
  alias FactsVsEvents.UserEventRepo
  import Ecto.Query, only: [from: 2]

  test "reconstruct state from just created object" do
    CreateUserCommand.execute(1, %{name: "a_name", email: "an_email"})
    user = UserEventRepo.get_events_for_user_with(uuid: 1) 
           |> UserStateHandler.current_state_from()
    assert user.params["name"] == "a_name"
    assert user.params["email"] == "an_email"
  end

  test "after creation and changes User has the right state" do
    CreateUserCommand.execute(1, %{name: "a_name", email: "an_email"})
    ChangeUserCommand.execute(1, %{name: "other_name"})
    ChangeUserCommand.execute(1, %{name: "another_name"})
    user = UserEventRepo.get_events_for_user_with(uuid: 1) 
           |> UserStateHandler.current_state_from()
    assert user.params["name"] == "another_name"
    assert user.params["email"] == "an_email"
  end

  test "after delete User is empty" do
    CreateUserCommand.execute(1, %{name: "a_name", email: "an_email"})
    ChangeUserCommand.execute(1, %{name: "other_name"})
    DeleteUserCommand.execute(1)
    user = UserEventRepo.get_events_for_user_with(uuid: 1) 
           |> UserStateHandler.current_state_from()
    assert user.params == %{}
  end

  test "construct all the users" do
    CreateUserCommand.execute(1, %{name: "a_name", email: "an_email"})
    CreateUserCommand.execute(2, %{name: "b_name", email: "an_email"})
    users = UserEventRepo.uuids
           |> UserStateHandler.all(with_repo: UserEventRepo)
    assert Enum.at(users, 0).params["name"] == "a_name"
    assert Enum.at(users, 1).params["name"] == "b_name"
  end
end
