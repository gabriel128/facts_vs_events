defmodule FactsVsEvents.ChangeUserCommand do
  alias FactsVsEvents.Repo

  def execute(uuid, data) do
    Repo.insert!(%FactsVsEvents.UserEvent{uuid: uuid, event_type: "UserChanged", data: data})
  end
end
