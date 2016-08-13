defmodule FactsVsEvents.Events.UserStateHandlerTest do
  use FactsVsEvents.ModelCase
  alias FactsVsEvents.Events.CreateUserCommand
  alias FactsVsEvents.Events.ChangeUserCommand
  alias FactsVsEvents.Events.DeleteUserCommand
  alias FactsVsEvents.Events.UserStateHandler
  alias FactsVsEvents.Events.UserEvent
  alias FactsVsEvents.Events.UserRepo
  alias FactsVsEvents.LoginUser
  alias FactsVsEvents.AuthService
  alias FactsVsEvents.EventsUuidMapper
  alias FactsVsEvents.Events.LoginUserEventFilter
  import Ecto.Query, only: [from: 2]

  test "reconstruct state from just created object" do
    create_user
    user = UserRepo.find(uuid: 1, with: UserStateHandler)
    assert user.name == "a_name"
    assert user.email == "an_email"
    assert user.uuid == 1
  end

  test "after creation and changes User has the right state" do
    create_user
    last_uuid = Repo.one(from u in UserEvent, select: max(u.uuid))
    ChangeUserCommand.execute(last_uuid, %{name: "other_name"})
    ChangeUserCommand.execute(last_uuid, %{name: "another_name"})
    user = UserRepo.find(uuid: last_uuid, with: UserStateHandler)
    assert user.name == "another_name"
    assert user.email == "an_email"
  end

  test "after delete User is empty" do
    uuid = create_user
    change_user_with(uuid) 
    delete_user_with(uuid)
    user = UserRepo.find(uuid: 1, with: UserStateHandler)
    assert user == %{}
  end

  test "construct all the users" do
    CreateUserCommand.execute(%{name: "a_name", email: "an_email"})
    CreateUserCommand.execute(%{name: "b_name", email: "an_email"})
    users = UserRepo.uuids
           |> UserStateHandler.all2(%{with: "", with_repo: UserRepo})
    assert Enum.at(users, 0).name == "a_name"
    assert Enum.at(users, 1).name == "b_name"
  end

  test "construct all the users without the deleted one" do
    create_user
    create_user
    DeleteUserCommand.execute(2)
    users = UserRepo.uuids
           |> UserStateHandler.all(with_repo: UserRepo)
    assert length(users) == 1
  end

  test "just returning events by user owner uuids" do
    uuid = create_user
    change_user_with(uuid) 
    create_user("b_name")
    user = create_login_user
    {:ok, user} = EventsUuidMapper.add_uuid_to_user(user, uuid)
    event_users = UserRepo.uuids |> UserStateHandler.all(with_repo: UserRepo)
    found = LoginUserEventFilter.filter_events_given(event_users, user)
    assert Enum.at(found, 0).name == "another_name"
  end

  test "single event filtered by user owner uuid" do
    uuid = create_user
    user = create_login_user
    {:ok, user} = EventsUuidMapper.add_uuid_to_user(user, uuid)
    event_users = UserRepo.uuids |> UserStateHandler.all(with_repo: UserRepo)
    found = LoginUserEventFilter.filter_events_given(event_users, user)
    assert Enum.at(found, 0).name == "a_name"
  end

  defp create_login_user do
    login_user = LoginUser.changeset(%LoginUser{}, %{name: "a", email: "m@m", password: "1234"})
    {:ok, user} = AuthService.register(login_user)
    user
  end

  defp delete_user_with(uuid) do
    DeleteUserCommand.execute(uuid)
  end

  defp create_user(name) do
    {:ok, uuid} = CreateUserCommand.execute(%{name: name, email: "an_email"})
    uuid
  end

  defp create_user do
    {:ok, uuid} = CreateUserCommand.execute(%{name: "a_name", email: "an_email"})
    uuid
  end

  defp change_user_with(uuid) do
    ChangeUserCommand.execute(uuid, %{name: "another_name"})
  end

end
