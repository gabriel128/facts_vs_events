defmodule FactsVsEvents.EventUserController do
  use FactsVsEvents.Web, :controller

  alias FactsVsEvents.EventUser

  plug :scrub_params, "event_user" when action in [:create, :update]

  def index(conn, _params) do
    event_users = Repo.all(EventUser)
    render(conn, "index.html", event_users: event_users)
  end

  def new(conn, _params) do
    changeset = EventUser.changeset(%EventUser{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event_user" => event_user_params}) do
    changeset = EventUser.changeset(%EventUser{}, event_user_params)

    case Repo.insert(changeset) do
      {:ok, _event_user} ->
        conn
        |> put_flash(:info, "Event user created successfully.")
        |> redirect(to: event_user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    event_user = Repo.get!(EventUser, id)
    render(conn, "show.html", event_user: event_user)
  end

  def edit(conn, %{"id" => id}) do
    event_user = Repo.get!(EventUser, id)
    changeset = EventUser.changeset(event_user)
    render(conn, "edit.html", event_user: event_user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event_user" => event_user_params}) do
    event_user = Repo.get!(EventUser, id)
    changeset = EventUser.changeset(event_user, event_user_params)

    case Repo.update(changeset) do
      {:ok, event_user} ->
        conn
        |> put_flash(:info, "Event user updated successfully.")
        |> redirect(to: event_user_path(conn, :show, event_user))
      {:error, changeset} ->
        render(conn, "edit.html", event_user: event_user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    event_user = Repo.get!(EventUser, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(event_user)

    conn
    |> put_flash(:info, "Event user deleted successfully.")
    |> redirect(to: event_user_path(conn, :index))
  end
end
