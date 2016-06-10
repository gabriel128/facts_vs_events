defmodule FactsVsEvents.EventUserGetController do
  use FactsVsEvents.Web, :controller
  alias FactsVsEvents.Events.{UserReadingCache, User, UserEvent, UserRepo, LoginUserEventFilter}
  import FactsVsEvents.AuthService, only: [current_user: 1, logged_in?: 1]

  def index(conn, _params) do
    users =
      UserReadingCache.all_users
      |> LoginUserEventFilter.filter_events_given(current_user(conn))
    events =
      Repo.all(UserEvent)
      |> LoginUserEventFilter.filter_events_given(current_user(conn))
    render(conn, FactsVsEvents.EventUserView, "index.html", users: users, events: events)
  end

  def new(conn, _params) do
    render(conn, FactsVsEvents.EventUserView, "new.html", user: %User{})
  end

  def show(conn, %{"id" => uuid}) do
    fetch_user_and_render(conn, uuid, "show.html")
  end

  def edit(conn, %{"id" => uuid}) do
    fetch_user_and_render(conn, uuid, "edit.html")
  end

  defp fetch_user_and_render(conn, uuid, template) do
    String.to_integer(uuid)
    |> UserReadingCache.get_user_by_uuid()
    |> LoginUserEventFilter.filter_single_event_given(current_user(conn))
    |> case do
        {:ok, user} -> render(conn, FactsVsEvents.EventUserView, template, user: user)
        {:error} ->
           conn
           |> put_status(:not_found)
           |> render(FactsVsEvents.ErrorView, "404.html")
    end
  end
end
