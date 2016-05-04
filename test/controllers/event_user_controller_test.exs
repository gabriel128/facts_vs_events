defmodule FactsVsEvents.EventUserControllerTest do
  use FactsVsEvents.ConnCase
  alias FactsVsEvents.EventUser
  alias FactsVsEvents.CreateUserCommand
  alias FactsVsEvents.UserStateHandler
  alias FactsVsEvents.UserEventRepo

  @valid_attrs %{email: "some content", name: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, event_user_path(conn, :index)
    assert html_response(conn, 200) =~ "Events"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, event_user_path(conn, :new)
    assert html_response(conn, 200) =~ "New event user"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, event_user_path(conn, :create), event_user: @valid_attrs
    assert redirected_to(conn) == event_user_path(conn, :index)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, event_user_path(conn, :create), event_user: @invalid_attrs
    assert html_response(conn, 200) =~ "New event user"
  end

  test "shows chosen resource", %{conn: conn} do
    response = CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
    event_user = UserEventRepo.get_events_for_user_with(uuid: 1) 
                  |> UserStateHandler.current_state_from()
    conn = get conn, event_user_path(conn, :show, event_user.uuid)
    assert html_response(conn, 200) =~ "Show event user"
  end

  # test "renders page not found when id is nonexistent", %{conn: conn} do
  #   assert_error_sent 404, fn ->
  #     get conn, event_user_path(conn, :show, -1)
  #   end
  # end

  test "renders form for editing chosen resource", %{conn: conn} do
    CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
    event_user = UserEventRepo.get_events_for_user_with(uuid: 1) 
                  |> UserStateHandler.current_state_from()
    conn = get conn, event_user_path(conn, :edit, event_user.uuid)
    assert html_response(conn, 200) =~ "Edit event user"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
    event_user = UserEventRepo.get_events_for_user_with(uuid: 1) 
                  |> UserStateHandler.current_state_from()
    conn = put conn, event_user_path(conn, :update, event_user.uuid), event_user: @valid_attrs
    assert redirected_to(conn) == event_user_path(conn, :index)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
    event_user = UserEventRepo.get_events_for_user_with(uuid: 1) 
                  |> UserStateHandler.current_state_from()
    conn = put conn, event_user_path(conn, :update, event_user.uuid), event_user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit event user"
  end

  test "deletes chosen resource", %{conn: conn} do
    conn = delete conn, event_user_path(conn, :delete, 1)
    assert redirected_to(conn) == event_user_path(conn, :index)
  end
end
