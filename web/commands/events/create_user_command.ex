defmodule FactsVsEvents.Events.CreateUserCommand do
  alias FactsVsEvents.Events.CommandResponseTransformer
  alias FactsVsEvents.Events.UserEvent
  alias FactsVsEvents.Events.UserRepo

  def execute(%{email: nil, name: _}),  do: {:error, "Missing email"}
  def execute(%{name: nil, email: _}),  do: {:error, "Missing name"}

  def execute(%{name: _ , email: _ } = data, repo \\ UserRepo) do
    last_uuid = repo.last_uuid
    %UserEvent{uuid: last_uuid + 1, event_type: "UserCreated", data: data}
    |> repo.insert()
    |> CommandResponseTransformer.build_response_with_uuid(last_uuid)
  end
  def execute(%{}, _), do: {:error, "Missing attributes"}
end
