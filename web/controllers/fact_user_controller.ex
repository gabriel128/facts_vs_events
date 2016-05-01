defmodule FactsVsEvents.FactUserController do
  use FactsVsEvents.Web, :controller

  alias FactsVsEvents.FactUser
  alias FactsVsEvents.FactRepo

  plug :scrub_params, "fact_user" when action in [:create, :update]

  def index(conn, _params) do
    all_table_users = Repo.all(FactUser)
    fact_users = FactRepo.all(FactUser)
    render(conn, "index.html", fact_users: fact_users, all_table_users: all_table_users)
  end

  def new(conn, _params) do
    changeset = FactUser.changeset(%FactUser{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"fact_user" => fact_user_params}) do
    changeset = FactUser.changeset(%FactUser{}, fact_user_params)

    case FactRepo.create(FactUser, changeset, commit_message: "Create new user from FactUserController") do
      {:ok, _fact_user} ->
        conn
        |> put_flash(:info, "Fact user created successfully.")
        |> redirect(to: fact_user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => uuid}) do
    fact_user = FactRepo.get!(FactUser, uuid)
    render(conn, "show.html", fact_user: fact_user)
  end

  def edit(conn, %{"id" => uuid}) do
    fact_user = FactRepo.get!(FactUser, uuid)
    changeset = FactUser.changeset(fact_user)
    render(conn, "edit.html", fact_user: fact_user, changeset: changeset)
  end

  def update(conn, %{"id" => uuid, "fact_user" => fact_user_params}) do
    fact_user = FactRepo.get!(FactUser, uuid)
    changeset = FactUser.changeset(fact_user, fact_user_params)

    case FactRepo.update(changeset, commit_message: "Update user from fact_user_controller") do
      {:ok, fact_user} ->
        conn
        |> put_flash(:info, "Fact user updated successfully.")
        |> redirect(to: fact_user_path(conn, :show, fact_user.uuid))
      {:error, changeset} ->
        render(conn, "edit.html", fact_user: fact_user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => uuid}) do
    FactRepo.get!(FactUser, uuid) |> FactRepo.delete(commit_message: "Delete the User")
    conn
    |> put_flash(:info, "Fact user deleted successfully.")
    |> redirect(to: fact_user_path(conn, :index))
  end
end
