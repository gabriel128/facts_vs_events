defmodule FactsVsEvents.ChangeUserCommand do
  alias FactsVsEvents.Repo

  def execute(data) do
    Repo.insert!(%FactsVsEvents.UserEvent{event_type: "UserChanged", data: data})
  end
end
