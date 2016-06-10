defmodule FactsVsEvents.Events.ReadingCache.Tests do
  use FactsVsEvents.ModelCase
  alias FactsVsEvents.Events.{CreateUserCommand, UserReadingCache, UserReadingCacheSupervisor}

  test "reading all the users from the cache" do
    CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
    CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
    UserReadingCacheSupervisor.start_link(:test_sup)
    assert length(UserReadingCache.all_users(:test_sup)) == 2
  end

  test "killing the cache without supervisor kills it" do
    UserReadingCacheSupervisor.start_link(:test_sup)
    Process.whereis(:reading_cache) |> Process.exit(:kill)
    assert Process.whereis(:test_sup) != nil
  end

  test "killing the cache with supervisor rebuild the cache" do
    CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
    CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
    UserReadingCacheSupervisor.start_link(:test_sup)
    Process.whereis(:test_sup) |> Process.exit(:kill)
    :timer.sleep(1)
    assert length(UserReadingCache.all_users(:test_sup)) == 2
  end

  test "get_user_by_uuid returns an specific user in its final state" do
    CreateUserCommand.execute(%{name: "sdf", email: "asdf"})
    CreateUserCommand.execute(%{name: "a_name", email: "asdf"})
    UserReadingCacheSupervisor.start_link(:test_sup)
    assert UserReadingCache.get_user_by_uuid(2, :test_sup).name == "a_name"
  end

  test "add_user function add users to the cache" do
    UserReadingCacheSupervisor.start_link(:test_sup)
    UserReadingCache.add_user(%{name: 3}, :test_sup)
    UserReadingCache.add_user(%{name: 3}, :test_sup)
    assert length(UserReadingCache.all_users(:test_sup)) == 2
  end
  
  test "delete function deletes an specific user from the cache" do
    UserReadingCacheSupervisor.start_link(:test_sup)
    UserReadingCache.add_user(%{uuid: 3, name: 2}, :test_sup)
    UserReadingCache.add_user(%{uuid: 4, name: 3}, :test_sup)
    UserReadingCache.delete_user(3, :test_sup)
    assert length(UserReadingCache.all_users(:test_sup)) == 1
    assert List.last(UserReadingCache.all_users(:test_sup)).uuid == 4
  end

  test "update function updates the cache" do
    UserReadingCacheSupervisor.start_link(:test_sup)
    UserReadingCache.add_user(%{uuid: 3, name: "old_name"}, :test_sup)
    UserReadingCache.update_user(3, %{uuid: 3, name: "something"}, :test_sup)
    assert length(UserReadingCache.all_users(:test_sup)) == 1
    assert UserReadingCache.get_user_by_uuid(3, :test_sup).name == "something"
  end
end
