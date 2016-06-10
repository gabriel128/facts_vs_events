defmodule FactsVsEvents.Events.UserReadingCacheServer do
  use GenServer
  alias FactsVsEvents.Events.{User, UserStateHandler, UserRepo}

  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def init(_) do
    users = UserRepo.uuids |> UserStateHandler.all(with_repo: UserRepo)
    {:ok, users || []}
  end

  def handle_call(:all_users, _from,  users) do
    {:reply, users, users}
  end

  def handle_call({:add_user, user}, _from, users) do
    {:reply, user, [ user | users ]}
  end

  def handle_call({:delete_user, uuid}, _from, users) do
    user_to_delete = Enum.filter(users, fn (user) -> user.uuid == uuid end)
    users = List.delete(users, user_to_delete)
    {:reply, :ok, users}
  end

  def handle_call({:get_user_by_uuid, uuid}, _from,  users) do
    user = Enum.filter(users, fn (user) -> user.uuid == uuid end) |> List.first
    {:reply, user, users}
  end

  def handle_call({:update_user, uuid, user}, _from, users) do
    list_without_user = Enum.filter(users, fn (user) -> user.uuid != uuid end)  
    {:reply, user, [user | users]}
  end
end
