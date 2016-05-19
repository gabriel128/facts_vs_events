defmodule FactsVsEvents.Events.ChangeUserCommand do
  alias FactsVsEvents.Events.UserRepo
  alias FactsVsEvents.Events.UserStateHandler
  alias FactsVsEvents.Events.CommandResponseTransformer
  alias FactsVsEvents.Events.UserEvent

  def execute(_, %{email: nil, name: _}),  do: {:error, "Missing email"}
  def execute(_, %{email: _, name: nil }),  do: {:error, "Missing name"}

  def execute(uuid, data, repo \\ UserRepo) do
    %UserEvent{uuid: uuid, event_type: "UserChanged",
               data: Map.new(new_data_with(uuid, data, repo))}
    |> repo.insert()
    |> CommandResponseTransformer.build_response()
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
