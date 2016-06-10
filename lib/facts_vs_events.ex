defmodule FactsVsEvents do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(FactsVsEvents.Endpoint, []),
      supervisor(FactsVsEvents.Repo, []),
      supervisor(FactsVsEvents.Events.UserReadingCacheSupervisor, [])
    ]
    opts = [strategy: :one_for_one, name: FactsVsEvents.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    FactsVsEvents.Endpoint.config_change(changed, removed)
    :ok
  end
end
