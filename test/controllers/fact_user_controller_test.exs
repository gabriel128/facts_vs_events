defmodule FactsVsEvents.FactUserControllerTest do
  use FactsVsEvents.ConnCase

  alias FactsVsEvents.FactUser
  @valid_attrs %{email: "some content", name: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, fact_user_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing fact users"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, fact_user_path(conn, :new)
    assert html_response(conn, 200) =~ "New fact user"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, fact_user_path(conn, :create), fact_user: @valid_attrs
    assert redirected_to(conn) == fact_user_path(conn, :index)
    assert Repo.get_by(FactUser, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, fact_user_path(conn, :create), fact_user: @invalid_attrs
    assert html_response(conn, 200) =~ "New fact user"
  end

  test "shows chosen resource", %{conn: conn} do
    fact_user = Repo.insert! %FactUser{}
    conn = get conn, fact_user_path(conn, :show, fact_user)
    assert html_response(conn, 200) =~ "Show fact user"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, fact_user_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    fact_user = Repo.insert! %FactUser{}
    conn = get conn, fact_user_path(conn, :edit, fact_user)
    assert html_response(conn, 200) =~ "Edit fact user"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    fact_user = Repo.insert! %FactUser{}
    conn = put conn, fact_user_path(conn, :update, fact_user), fact_user: @valid_attrs
    assert redirected_to(conn) == fact_user_path(conn, :show, fact_user)
    assert Repo.get_by(FactUser, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    fact_user = Repo.insert! %FactUser{}
    conn = put conn, fact_user_path(conn, :update, fact_user), fact_user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit fact user"
  end

  test "deletes chosen resource", %{conn: conn} do
    fact_user = Repo.insert! %FactUser{}
    conn = delete conn, fact_user_path(conn, :delete, fact_user)
    assert redirected_to(conn) == fact_user_path(conn, :index)
    refute Repo.get(FactUser, fact_user.id)
  end
end
