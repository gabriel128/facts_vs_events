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
    {:ok, users}
  end

  def handle_cast({:add_user, user}, users) do
    {:noreply, [ user | users ]}
  end

  def handle_call(:all_users, _from,  users) do
    {:reply, users, users}
  end

  def handle_call({:get_user_by_uuid, uuid}, _from,  users) do
    user = Enum.filter(users, fn (user) -> user.uuid == uuid end) |> List.first
    {:reply, user, user}
  end
end

defmodule UserReadingCache do

  def start_link() do
    UserReadingCacheServer.start_link()
  end

  def add_user(user) do
    GenServer.cast(:reading_cache, {:add_user, user})
  end

  def all_users() do
    GenServer.call(:reading_cache, :all_users)
  end

  def get_user_by_uuid(uuid) do
    GenServer.call(:reading_cache, {:get_user_by_uuid, uuid})
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
end
