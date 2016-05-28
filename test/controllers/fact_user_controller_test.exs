defmodule FactsVsEvents.FactUserControllerTest do
  use FactsVsEvents.ConnCase
  use FactsVsEvents.FakeLogin

  alias FactsVsEvents.Fact.User
  alias FactsVsEvents.FactRepo
  @valid_attrs %{email: "some content", name: "some content", owner_id: 1}
  @invalid_attrs %{}

  test "not logged in redirects to login page" do
    conn = get conn, fact_user_path(conn, :index)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "lists all entries on index", %{conn: conn} do
    with_auth_mocked do
      conn = get conn, fact_user_path(conn, :index)
      assert html_response(conn, 200) =~ "Users generated by Facts"
    end
  end

  test "renders form for new resources", %{conn: conn} do
    with_auth_mocked do
      conn = get conn, fact_user_path(conn, :new)
      assert html_response(conn, 200) =~ "New fact user"
    end
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    with_auth_mocked do
      conn = post conn, fact_user_path(conn, :create), fact_user: @valid_attrs
      assert redirected_to(conn) == fact_user_path(conn, :index)
      assert Repo.get_by(User, @valid_attrs)
    end
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    with_auth_mocked do
      conn = post conn, fact_user_path(conn, :create), fact_user: @invalid_attrs
      assert html_response(conn, 200) =~ "New fact user"
    end
  end

  test "shows chosen resource", %{conn: conn} do
    with_auth_mocked do
      {:ok, fact_user } = create_user
      conn = get conn, fact_user_path(conn, :show, fact_user.uuid)
      assert html_response(conn, 200) =~ "Show fact user"
    end
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    with_auth_mocked do
      assert_error_sent 404, fn ->
        get conn, fact_user_path(conn, :show, -1)
      end
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    with_auth_mocked do
      {:ok, fact_user } = create_user
      conn = get conn, fact_user_path(conn, :edit, fact_user.uuid)
      assert html_response(conn, 200) =~ "Edit fact user"
    end
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    with_auth_mocked do
      {:ok, fact_user } = create_user
      conn = put conn, fact_user_path(conn, :update, fact_user.uuid), fact_user: %{name: "a_name"}
      assert redirected_to(conn) == fact_user_path(conn, :index)
    end
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    with_auth_mocked do
      {:ok, fact_user } = create_user
      conn = put conn, fact_user_path(conn, :update, fact_user.uuid), fact_user: %{"email": nil}
      assert html_response(conn, 200) =~ "Edit fact user"
    end
  end

  test "deletes chosen resource", %{conn: conn} do
    with_auth_mocked do
      {:ok, fact_user } = create_user
      conn = delete conn, fact_user_path(conn, :delete, fact_user.uuid)
      assert redirected_to(conn) == fact_user_path(conn, :index)
    end
  end

  defp create_user do
    User.changeset(%User{}, @valid_attrs)
    |> FactRepo.create(User)
  end
end
