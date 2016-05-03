defmodule FactsVsEvents.CreateUserCommand do
  alias FactsVsEvents.Repo

  def execute(uuid, data) do
    Repo.insert!(%FactsVsEvents.UserEvent{uuid: uuid,  event_type: "UserCreated", data: data})
  end
end
