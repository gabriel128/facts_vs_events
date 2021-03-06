defmodule FactsVsEvents.EventUserTransformationController do
  use FactsVsEvents.Web, :controller
  alias FactsVsEvents.Events.{CreateUserCommand, ChangeUserCommand, DeleteUserCommand, UserRepo, User, UserStateHandler, UserReadingCache}
  alias FactsVsEvents.{JsonTransformer, EventsUuidMapper}
  import FactsVsEvents.AuthService, only: [current_user: 1, logged_in?: 1]

  plug :scrub_params, "user" when action in [:create, :update]
  plug :params_keys_to_atoms when action in [:create]

  def params_keys_to_atoms(conn, _) do
    params = JsonTransformer.keys_to_atoms(conn.params["user"])
    %{conn | params: %{user: params}}
  end

  def create(conn, %{user: user_params}) do
    CreateUserCommand.execute(user_params)
    |> case do
      {:ok, uuid} ->
        EventsUuidMapper.add_uuid_to_user(current_user(conn), uuid)
        UserReadingCache.add_user(UserRepo.find(uuid: uuid, with: UserStateHandler))
        conn
        |> put_flash(:info, "Event user created successfully.")
        |> redirect(to: event_user_path(conn, :index))
      {:error, errors} -> 
        user = Map.merge %User{}, user_params
        render(conn, FactsVsEvents.EventUserView, "new.html", user: user, errors: errors)
    end
  end

  def update(conn, %{"id" => uuid, "user" => event_user_params}) do
    String.to_integer(uuid)
    |> ChangeUserCommand.execute(event_user_params)
    |> case do
        {:ok} ->
          String.to_integer(uuid)
          |> UserReadingCache.update_user(UserRepo.find(uuid: uuid, with: UserStateHandler))
          conn
          |> put_flash(:info, "Event user updated successfully.")
          |> redirect(to: event_user_path(conn, :index))
        {:error, errors} -> 
          user = Map.merge %User{}, event_user_params
          render(conn, FactsVsEvents.EventUserView, "edit.html", user: %{ user | uuid: uuid}, errors: errors)
      end
  end

  def delete(conn, %{"id" => uuid}) do
    uuid = String.to_integer(uuid)
    DeleteUserCommand.execute(uuid)
    UserReadingCache.delete_user(uuid)
    conn
    |> put_flash(:info, "Event user deleted successfully.")
    |> redirect(to: event_user_path(conn, :index))
  end
end
