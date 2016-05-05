defmodule FactsVsEvents.UserStateHandler do
  alias FactsVsEvents.EventUser
  alias FactsVsEvents.JsonTransformer

  def all(event_uuids, [with_repo: repo]) do
    Enum.reduce(event_uuids, [], fn (uuid, acc) ->
      user = repo.get_events_for_user_with(uuid: uuid) 
             |> current_state_from()
      acc ++ [user]
    end)
    |> Enum.filter(fn (user) -> user != %{} end)
  end

  def current_state_from(events) do
    Enum.reduce(events, %{}, fn (event, acc) ->
      handle(event, event.event_type, acc)
    end)
  end

  defp handle(event, "UserCreated", acc) do
    data = JsonTransformer.keys_to_atoms(event.data)
    user_hash = Map.merge(acc, data) |> Map.merge(%{uuid: event.uuid})
    Map.merge %EventUser{}, user_hash 
  end

  defp handle(event, "UserChanged", acc) do
    data = JsonTransformer.keys_to_atoms(event.data)
    user_hash = Map.merge(acc, data)
    Map.merge %EventUser{}, user_hash 
  end

  defp handle(_, "UserDeleted", _) do
    %{}
  end
end
