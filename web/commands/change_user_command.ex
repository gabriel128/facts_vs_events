defmodule FactsVsEvents.ChangeUserCommand do
  alias FactsVsEvents.Repo
  alias FactsVsEvents.RepoResponseTransformer

  def execute(uuid, data) do
    Repo.insert(%FactsVsEvents.UserEvent{uuid: uuid, event_type: "UserChanged", data: data})
    |> RepoResponseTransformer.build_response()
  end
end
