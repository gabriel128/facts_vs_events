defmodule FactsVsEvents.Events.DeleteUserCommand do
  alias FactsVsEvents.Events.UserRepo
  alias FactsVsEvents.Events.CommandResponseTransformer

  def execute(uuid, repo \\ UserRepo) do
    %FactsVsEvents.Events.UserEvent{uuid: uuid, event_type: "UserDeleted"}
    |> repo.insert()
    |> CommandResponseTransformer.build_response()
  end
end
