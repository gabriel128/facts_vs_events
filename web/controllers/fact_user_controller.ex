defmodule FactsVsEvents.FactUserController do
  use FactsVsEvents.Web, :controller

  alias FactsVsEvents.FactUser

  plug :scrub_params, "fact_user" when action in [:create, :update]

  def index(conn, _params) do
    fact_users = Repo.all(FactUser)
    render(conn, "index.html", fact_users: fact_users)
  end

  def new(conn, _params) do
    changeset = FactUser.changeset(%FactUser{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"fact_user" => fact_user_params}) do
    changeset = FactUser.changeset(%FactUser{}, fact_user_params)

    case Repo.insert(changeset) do
      {:ok, _fact_user} ->
        conn
        |> put_flash(:info, "Fact user created successfully.")
        |> redirect(to: fact_user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    fact_user = Repo.get!(FactUser, id)
    render(conn, "show.html", fact_user: fact_user)
  end

  def edit(conn, %{"id" => id}) do
    fact_user = Repo.get!(FactUser, id)
    changeset = FactUser.changeset(fact_user)
    render(conn, "edit.html", fact_user: fact_user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "fact_user" => fact_user_params}) do
    fact_user = Repo.get!(FactUser, id)
    changeset = FactUser.changeset(fact_user, fact_user_params)

    case Repo.update(changeset) do
      {:ok, fact_user} ->
        conn
        |> put_flash(:info, "Fact user updated successfully.")
        |> redirect(to: fact_user_path(conn, :show, fact_user))
      {:error, changeset} ->
        render(conn, "edit.html", fact_user: fact_user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    fact_user = Repo.get!(FactUser, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(fact_user)

    conn
    |> put_flash(:info, "Fact user deleted successfully.")
    |> redirect(to: fact_user_path(conn, :index))
  end
end
