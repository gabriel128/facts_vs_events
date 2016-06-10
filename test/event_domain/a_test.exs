defmodule UserReadingCacheSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      worker(UserReadingCache, [])
    ]

    supervise(children, strategy: :one_for_one)
  end

end
defmodule UserReadingCacheServer do
  use GenServer

  alias FactsVsEvents.Events.{User, UserStateHandler, UserRepo}

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: :reading_cache)
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

defmodule UserReadingCache do

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

defmodule FactsVsEvents.ATest do
  use FactsVsEvents.ModelCase
  alias FactsVsEvents.Events.CreateUserCommand

  test "" do
    CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
    CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
    UserReadingCacheSupervisor.start_link
    assert length(UserReadingCache.all_users) == 2
  end

  test "asdf" do
    UserReadingCacheSupervisor.start_link
    Process.whereis(:reading_cache) |> Process.exit(:kill)
    assert Process.whereis(:reading_cache) != nil
  end

  test "asdfsdf" do
    CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
    CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
    UserReadingCacheSupervisor.start_link
    Process.whereis(:reading_cache) |> Process.exit(:kill)
    :timer.sleep(1)
    assert length(UserReadingCache.all_users) == 2
  end

  test "2" do
    CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
    CreateUserCommand.execute(%{name: "a_name", email: "asdf"})
    UserReadingCacheSupervisor.start_link
    assert UserReadingCache.get_user_by_uuid(2).name == "a_name"
  end

  test "add" do
    UserReadingCacheSupervisor.start_link
    UserReadingCache.add_user(%{name: 3})
    UserReadingCache.add_user(%{name: 3})
    assert length(UserReadingCache.all_users) == 2
  end
  
  test "delete" do
    UserReadingCacheSupervisor.start_link
    UserReadingCache.add_user(%{uuid: 3, name: 2})
    UserReadingCache.add_user(%{uuid: 4, name: 3})
    UserReadingCache.delete_user(3)
    assert length(UserReadingCache.all_users) == 2
    assert List.last(UserReadingCache.all_users).uuid == 3
  end

  test "update" do
    UserReadingCacheSupervisor.start_link
    UserReadingCache.add_user(%{uuid: 3, name: "old_name"})
    UserReadingCache.update_user(3, %{uuid: 3, name: "something"})
    assert UserReadingCache.get_user_by_uuid(3).name == "something"
  end
end
