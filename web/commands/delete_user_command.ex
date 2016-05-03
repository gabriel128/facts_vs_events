defmodule FactsVsEvents.DeleteUserCommand do
  alias FactsVsEvents.Repo

  def execute do
    Repo.insert!(%FactsVsEvents.UserEvent{event_type: "UserDeleted"})
  end
end
