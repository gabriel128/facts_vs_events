defmodule FactsVsEvents.Events.UserReadingCacheSupervisor do
  use Supervisor
  alias FactsVsEvents.Events.UserReadingCache

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
