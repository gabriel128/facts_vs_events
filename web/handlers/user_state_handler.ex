defmodule FactsVsEvents.UserStateHandler do
  alias FactsVsEvents.EventUser

  def all(event_uuids, [with_repo: repo]) do
    Enum.reduce(event_uuids, [], fn (uuid, acc) ->
      user = repo.get_events_for_user_with(uuid: uuid) 
             |> current_state_from()
      acc ++ [user]
    end)
  end

  def current_state_from(events) do
    user_hash = Enum.reduce(events, %{}, fn (event, acc) ->
      handle(event, event.event_type, acc)
    end)
    EventUser.changeset(%EventUser{}, user_hash)
  end

  defp handle(event, "UserCreated", acc) do
    data = for {key, val} <- event.data, into: %{}, do: {String.to_atom(key), val}
    Map.merge(acc, data)
  end

  defp handle(event, "UserChanged", acc) do
    Map.merge(acc, event.data)
  end

  defp handle(_, "UserDeleted", _) do
    %{}
  end
end
