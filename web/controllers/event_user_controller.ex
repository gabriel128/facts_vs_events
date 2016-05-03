defmodule FactsVsEvents.EventUserController do
  use FactsVsEvents.Web, :controller
  alias FactsVsEvents.CreateUserCommand
  alias FactsVsEvents.ChangeUserCommand
  alias FactsVsEvents.DeleteUserCommand
  alias FactsVsEvents.UserStateHandler
  alias FactsVsEvents.EventUser
  alias FactsVsEvents.UserEvent
  alias FactsVsEvents.UserEventRepo

  plug :scrub_params, "event_user" when action in [:create, :update]

  def index(conn, _params) do
    event_users = UserEventRepo.uuids
                  |> UserStateHandler.all(with_repo: UserEventRepo)
    events = Repo.all(UserEvent)
    render(conn, "index.html", event_users: event_users, events: events)
  end

  def new(conn, _params) do
    changeset = EventUser.changeset(%EventUser{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event_user" => event_user_params}) do
    CreateUserCommand.execute(1, event_user_params)
    conn
    |> put_flash(:info, "Event user created successfully.")
    |> redirect(to: event_user_path(conn, :index))

    # case Repo.insert(changeset) do
    #   {:ok, _event_user} ->
    #     conn
    #     |> put_flash(:info, "Event user created successfully.")
    #     |> redirect(to: event_user_path(conn, :index))
    #   {:error, changeset} ->
    #     render(conn, "new.html", changeset: changeset)
    # end
  end

  def show(conn, %{"id" => _uuid}) do
    event_user = UserEventRepo.get_events_for_user_with(uuid: 1) 
                  |> UserStateHandler.current_state_from()
    render(conn, "show.html", event_user: event_user)
  end

  def edit(conn, %{"id" => _uuid}) do
    event_user = UserEventRepo.get_events_for_user_with(uuid: 1) 
                  |> UserStateHandler.current_state_from()
    changeset = EventUser.changeset(event_user)
    render(conn, "edit.html", event_user: event_user, changeset: changeset)
  end

  def update(conn, %{"id" => _uuid, "event_user" => event_user_params}) do
    ChangeUserCommand.execute(1, event_user_params)
    conn
    |> put_flash(:info, "Event user updated successfully.")
    |> redirect(to: event_user_path(conn, :index))

    # case Repo.update(changeset) do
    #   {:ok, event_user} ->
    #     conn
    #     |> put_flash(:info, "Event user updated successfully.")
    #     |> redirect(to: event_user_path(conn, :show, event_user))
    #   {:error, changeset} ->
    #     render(conn, "edit.html", event_user: event_user, changeset: changeset)
    # end
  end

  def delete(conn, %{"id" => _uuid}) do
    DeleteUserCommand.execute(1)
    conn
    |> put_flash(:info, "Event user deleted successfully.")
    |> redirect(to: event_user_path(conn, :index))
  end
end
