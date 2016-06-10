defmodule FactsVsEvents.Events.UserReadingCache do
  alias FactsVsEvents.Events.UserReadingCacheServer

  def add_user(user, server_name \\ :reading_cache) do
    GenServer.call(server_name, {:add_user, user})
  end

  def all_users(server_name \\ :reading_cache) do
    GenServer.call(server_name, :all_users)
  end

  def get_user_by_uuid(uuid, server_name \\ :reading_cache ) do
    GenServer.call(server_name, {:get_user_by_uuid, uuid})
  end

  def delete_user(uuid, server_name \\ :reading_cache ) do
    GenServer.call(server_name, {:delete_user, uuid})
  end

  def update_user(uuid, user, server_name \\ :reading_cache) do
    GenServer.call(server_name, {:update_user, uuid, user})
  end
end
