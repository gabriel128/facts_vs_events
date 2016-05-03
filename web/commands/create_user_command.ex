defmodule FactsVsEvents.CreateUserCommand do
  alias FactsVsEvents.Repo

  def execute(data) do
    Repo.insert!(%FactsVsEvents.UserEvent{event_type: "UserCreated", data: data})
  end
end
