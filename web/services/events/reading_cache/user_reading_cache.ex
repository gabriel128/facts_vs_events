defmodule FactsVsEvents.Events.UserReadingCache do
  alias FactsVsEvents.Events.UserReadingCacheServer

  def start_link() do
    UserReadingCacheServer.start_link()
  end

  def add_user(user) do
    GenServer.call(:reading_cache, {:add_user, user})
  end

  def all_users() do
    GenServer.call(:reading_cache, :all_users)
  end

  def get_user_by_uuid(uuid) do
    GenServer.call(:reading_cache, {:get_user_by_uuid, uuid})
  end

  def delete_user(uuid) do
    GenServer.call(:reading_cache, {:delete_user, uuid})
  end

  def update_user(uuid, user) do
    GenServer.call(:reading_cache, {:update_user, uuid, user})
  end
end
