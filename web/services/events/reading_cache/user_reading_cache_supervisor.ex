defmodule FactsVsEvents.Events.UserReadingCacheSupervisor do
  use Supervisor
  alias FactsVsEvents.Events.UserReadingCacheServer

  def start_link(name \\ :reading_cache) do
    Supervisor.start_link(__MODULE__, name)
  end

  def init(name) do
    children = [
      worker(UserReadingCacheServer, [name])
    ]

    supervise(children, strategy: :one_for_one)
  end

end
