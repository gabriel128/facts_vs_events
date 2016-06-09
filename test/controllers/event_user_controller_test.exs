defmodule FactsVsEvents.EventUserControllerTest do
  use FactsVsEvents.ConnCase
  alias FactsVsEvents.Events.User
  alias FactsVsEvents.LoginUser
  alias FactsVsEvents.Events.CreateUserCommand
  alias FactsVsEvents.Events.UserStateHandler
  alias FactsVsEvents.Events.UserRepo
  use FactsVsEvents.FakeLogin

  @valid_attrs %{email: "some@content", password: "somecontent"}
  @invalid_attrs %{}
  @default_opts [
    store: :cookie,
    key: "foobar",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt",
    log: false
  ]

  @secret String.duplicate("abcdef0123456789", 8)
  @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))
  @encrypted_opts Plug.Session.init(@default_opts)

  test "not logged in redirects to login page" do
    conn = get conn, event_user_path(conn, :index)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "lists all entries on index", %{conn: conn} do
    with_auth_mocked do
      conn = get conn, event_user_path(conn, :index)
      assert html_response(conn, 200) =~ "Events"
    end
  end

  test "renders form for new resources", %{conn: conn} do
    with_auth_mocked do
      conn = get conn, event_user_path(conn, :new)
      assert html_response(conn, 200) =~ "New event user"
    end
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    {:ok, a_user} = Repo.insert %LoginUser{email: "some@mail", name: "some", event_uuids: []}
    with_auth_mocked(a_user) do
      conn = post conn, event_user_path(conn, :create), user: %{email: "sdf", name: "sdf"}
      assert redirected_to(conn) == event_user_path(conn, :index)
    end
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    with_auth_mocked do
      conn = post conn, event_user_path(conn, :create), user: %{email: nil, name: "sdf"}
      assert html_response(conn, 200) =~ "New event user"
    end
  end

  test "shows chosen resource", %{conn: conn} do
    {login_user, event_uuid} = create_login_user_and_event
    with_auth_mocked(login_user) do
      user = UserRepo.find(uuid: event_uuid, with: UserStateHandler)
      conn = get conn, event_user_path(conn, :show, user.uuid)
      assert html_response(conn, 200) =~ "Show event user"
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    {user, event_uuid} = create_login_user_and_event
    with_auth_mocked(user) do
      event_user = UserRepo.find(uuid: 1, with: UserStateHandler)
      conn = get conn, event_user_path(conn, :edit, event_user.uuid)
      assert html_response(conn, 200) =~ "Edit event user"
    end
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    with_auth_mocked do
      CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
      user = UserRepo.find(uuid: 1, with: UserStateHandler)
      conn = put conn, event_user_path(conn, :update, user.uuid), user: @valid_attrs
      assert redirected_to(conn) == event_user_path(conn, :index)
    end
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    with_auth_mocked do
      CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
      user = UserRepo.find(uuid: 1, with: UserStateHandler)
      conn = put conn, event_user_path(conn, :update, user.uuid), user: @invalid_attrs
      assert html_response(conn, 302)
    end
  end

  test "deletes chosen resource", %{conn: conn} do
    with_auth_mocked do
      conn = delete conn, event_user_path(conn, :delete, 1)
      assert redirected_to(conn) == event_user_path(conn, :index)
    end
  end

  defp create_login_user_and_event() do
    {:ok, a_user} = Repo.insert %LoginUser{email: "some@mail", name: "some", event_uuids: []}
    {:ok, uuid} = CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
    {:ok, a_user} = FactsVsEvents.EventsUuidMapper.add_uuid_to_user(a_user, uuid)
    {a_user, uuid}
  end
end

