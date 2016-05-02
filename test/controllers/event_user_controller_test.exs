defmodule FactsVsEvents.EventUserControllerTest do
  use FactsVsEvents.ConnCase

  alias FactsVsEvents.EventUser
  @valid_attrs %{email: "some content", name: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, event_user_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing event users"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, event_user_path(conn, :new)
    assert html_response(conn, 200) =~ "New event user"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, event_user_path(conn, :create), event_user: @valid_attrs
    assert redirected_to(conn) == event_user_path(conn, :index)
    assert Repo.get_by(EventUser, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, event_user_path(conn, :create), event_user: @invalid_attrs
    assert html_response(conn, 200) =~ "New event user"
  end

  test "shows chosen resource", %{conn: conn} do
    event_user = Repo.insert! %EventUser{}
    conn = get conn, event_user_path(conn, :show, event_user)
    assert html_response(conn, 200) =~ "Show event user"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, event_user_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    event_user = Repo.insert! %EventUser{}
    conn = get conn, event_user_path(conn, :edit, event_user)
    assert html_response(conn, 200) =~ "Edit event user"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    event_user = Repo.insert! %EventUser{}
    conn = put conn, event_user_path(conn, :update, event_user), event_user: @valid_attrs
    assert redirected_to(conn) == event_user_path(conn, :show, event_user)
    assert Repo.get_by(EventUser, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    event_user = Repo.insert! %EventUser{}
    conn = put conn, event_user_path(conn, :update, event_user), event_user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit event user"
  end

  test "deletes chosen resource", %{conn: conn} do
    event_user = Repo.insert! %EventUser{}
    conn = delete conn, event_user_path(conn, :delete, event_user)
    assert redirected_to(conn) == event_user_path(conn, :index)
    refute Repo.get(EventUser, event_user.id)
  end
end
