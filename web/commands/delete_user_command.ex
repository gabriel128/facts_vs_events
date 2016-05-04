defmodule FactsVsEvents.DeleteUserCommand do
  alias FactsVsEvents.Repo
  alias FactsVsEvents.RepoResponseTransformer

  def execute(uuid) do
    Repo.insert(%FactsVsEvents.UserEvent{uuid: uuid, event_type: "UserDeleted"})
    |> RepoResponseTransformer.build_response()
  end
end
