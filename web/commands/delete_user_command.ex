defmodule FactsVsEvents.DeleteUserCommand do
  alias FactsVsEvents.Repo

  def execute(uuid) do
    Repo.insert!(%FactsVsEvents.UserEvent{uuid: uuid, event_type: "UserDeleted"})
  end
end
