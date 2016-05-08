defmodule FactsVsEvents.EventUserControllerTest do
  use FactsVsEvents.ConnCase
  alias FactsVsEvents.EventUser
  alias FactsVsEvents.User
  alias FactsVsEvents.CreateUserCommand
  alias FactsVsEvents.UserStateHandler
  alias FactsVsEvents.UserEventRepo
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
    with_auth_mocked do
      conn = post conn, event_user_path(conn, :create), event_user: %{email: "sdf", name: "sdf"}
      assert redirected_to(conn) == event_user_path(conn, :index)
    end
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    with_auth_mocked do
      conn = post conn, event_user_path(conn, :create), event_user: @invalid_attrs
      assert html_response(conn, 200) =~ "New event user"
    end
  end

  test "shows chosen resource", %{conn: conn} do
    with_auth_mocked do
      response = CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
      event_user = UserEventRepo.find(uuid: 1, with: UserStateHandler)
      conn = get conn, event_user_path(conn, :show, event_user.uuid)
      assert html_response(conn, 200) =~ "Show event user"
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    with_auth_mocked do
      CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
      event_user = UserEventRepo.find(uuid: 1, with: UserStateHandler)
      conn = get conn, event_user_path(conn, :edit, event_user.uuid)
      assert html_response(conn, 200) =~ "Edit event user"
    end
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    with_auth_mocked do
      CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
      event_user = UserEventRepo.find(uuid: 1, with: UserStateHandler)
      conn = put conn, event_user_path(conn, :update, event_user.uuid), event_user: @valid_attrs
      assert redirected_to(conn) == event_user_path(conn, :index)
    end
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    with_auth_mocked do
      CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
      event_user = UserEventRepo.find(uuid: 1, with: UserStateHandler)
      conn = put conn, event_user_path(conn, :update, event_user.uuid), event_user: @invalid_attrs
      assert html_response(conn, 302)
    end
  end

  test "deletes chosen resource", %{conn: conn} do
    with_auth_mocked do
      conn = delete conn, event_user_path(conn, :delete, 1)
      assert redirected_to(conn) == event_user_path(conn, :index)
    end
  end
end

