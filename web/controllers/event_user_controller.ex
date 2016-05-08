defmodule FactsVsEvents.EventUserController do
  use FactsVsEvents.Web, :controller
  alias FactsVsEvents.CreateUserCommand
  alias FactsVsEvents.ChangeUserCommand
  alias FactsVsEvents.DeleteUserCommand
  alias FactsVsEvents.UserStateHandler
  alias FactsVsEvents.EventUser
  alias FactsVsEvents.UserEvent
  alias FactsVsEvents.UserEventRepo
  alias FactsVsEvents.JsonTransformer

  plug :scrub_params, "event_user" when action in [:create, :update]
  plug :params_keys_to_atoms when action in [:create]

  def params_keys_to_atoms(conn, _) do
    params = JsonTransformer.keys_to_atoms(conn.params["event_user"])
    %{conn | params: %{event_user: params}}
  end

  def index(conn, _params) do
    event_users = UserEventRepo.uuids
                  |> UserStateHandler.all(with_repo: UserEventRepo)
    events = Repo.all(UserEvent)
    render(conn, "index.html", event_users: event_users, events: events)
  end

  def new(conn, _params) do
    render(conn, "new.html", event_user: %EventUser{})
  end

  def create(conn, %{event_user: event_user_params}) do
    response = CreateUserCommand.execute(event_user_params)
    case response do
      {:ok} ->
        conn
        |> put_flash(:info, "Event user created successfully.")
        |> redirect(to: event_user_path(conn, :index))
      {:error, errors} -> 
        event_user = Map.merge %EventUser{}, event_user_params
        render(conn, "new.html", event_user: event_user, errors: errors)
    end
  end

  def show(conn, %{"id" => uuid}) do
    event_user = UserEventRepo.find(uuid: uuid, with: UserStateHandler)
    render(conn, "show.html", event_user: event_user)
  end

  def edit(conn, %{"id" => uuid}) do
    event_user = UserEventRepo.find(uuid: uuid, with: UserStateHandler)
    render(conn, "edit.html", event_user: event_user)
  end

  def update(conn, %{"id" => uuid, "event_user" => event_user_params}) do
    response = String.to_integer(uuid)
               |> ChangeUserCommand.execute(event_user_params)
    case response do
      {:ok} ->
        conn
        |> put_flash(:info, "Event user updated successfully.")
        |> redirect(to: event_user_path(conn, :index))
      {:error, errors} -> 
        params = JsonTransformer.keys_to_atoms(event_user_params)
        event_user = Map.merge %EventUser{}, params
        render(conn, "edit.html", event_user: %{ event_user | uuid: uuid}, errors: errors)
    end
  end

  def delete(conn, %{"id" => uuid}) do
    String.to_integer(uuid)
    |> DeleteUserCommand.execute()
    conn
    |> put_flash(:info, "Event user deleted successfully.")
    |> redirect(to: event_user_path(conn, :index))
  end
end
