defmodule FactsVsEvents.Events.LoginUserEventFilter do
  def filter_events_given(event_users, user) do
    Enum.filter(event_users, fn (event_user) ->
      event_user.uuid in user.event_uuids end
    ) || []
  end

  def filter_single_event_given(event_user, user) do
    case event_user.uuid in user.event_uuids do
      true -> {:ok, event_user}
      _ -> {:error}
    end
  end
end
