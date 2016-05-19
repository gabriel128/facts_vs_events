defmodule FactsVsEvents.Events.CreateUserCommand do
  alias FactsVsEvents.Events.CommandResponseTransformer
  alias FactsVsEvents.Events.UserEvent
  alias FactsVsEvents.Events.UserRepo


  def execute(data, repo \\ UserRepo) do
    with {:ok} <- UserValidator.validate(data),
         last_uuid = repo.last_uuid,
         event = %UserEvent{uuid: last_uuid + 1, event_type: "UserCreated", data: data},
         response <- repo.insert(event),
         do: CommandResponseTransformer.build_response_with_uuid(response, last_uuid)
  end

end

defmodule UserValidator do
  def validate(%{email: nil, name: _}),  do: {:error, "Missing email"}
  def validate(%{name: nil, email: _}),  do: {:error, "Missing name"}
  def validate(%{name: nil, email: nil}), do: {:error, "Missing attributes"}
  def validate(_), do: {:ok}
end
