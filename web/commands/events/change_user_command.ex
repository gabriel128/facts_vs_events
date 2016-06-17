defmodule FactsVsEvents.Events.ChangeUserCommand do
  alias FactsVsEvents.Events.{UserRepo, UserStateHandler}
  alias FactsVsEvents.Events.CommandResponseTransformer
  alias FactsVsEvents.Events.UserEvent
  alias FactsVsEvents.Events.UserValidator

  def execute(uuid, data, repo \\ UserRepo) do
    with {:ok} <- UserValidator.validate(data),
          event = %UserEvent{uuid: uuid, event_type: "UserChanged",
                             data: Map.new(new_data_with(uuid, data, repo))},
          response <-  repo.insert(event),
          do: CommandResponseTransformer.build_response(response)
  end

  defp new_data_with(uuid, data, repo) do
    Enum.filter(data, fn {k,v} -> 
      existing_value?(k, v, event_user_by(uuid, repo)) 
    end)
  end

  defp event_user_by(uuid, repo) do
    repo.find(uuid: uuid, with: UserStateHandler)
  end

  defp existing_value?(k, v, event_user) when is_atom(k) do
    Map.from_struct(event_user)[k] != v
  end

  defp existing_value?(k, v, event_user) do
    Map.from_struct(event_user)[String.to_atom(k)] != v
  end
end
