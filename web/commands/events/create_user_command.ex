defmodule FactsVsEvents.Events.CreateUserCommand do
  alias FactsVsEvents.Events.CommandResponseTransformer
  alias FactsVsEvents.Events.UserEvent
  alias FactsVsEvents.Events.UserRepo
  alias FactsVsEvents.Events.UserValidator

  def execute(data, repo \\ UserRepo) do
    with {:ok} <- UserValidator.validate(data),
         last_uuid = repo.last_uuid,
         event = %UserEvent{uuid: last_uuid + 1, event_type: "UserCreated", data: data},
         response <- repo.insert(event),
         do: CommandResponseTransformer.build_response_with_uuid(response, last_uuid)
  end
end
