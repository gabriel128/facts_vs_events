defmodule FactsVsEvents.UserEventsOwner do
  alias FactsVsEvents.Repo

  def add_uuid_to_user(user, uuid) do
    uuids = user.event_uuids ++ [uuid]
    changeset = Ecto.Changeset.change user, event_uuids: uuids
    Repo.update(changeset)
  end

  def filter_events_given(event_users, user) do
    Enum.filter(event_users, fn (event_user) -> event_user.uuid in user.event_uuids end) || []
  end

  def filter_event_given(event_user, user) do
    case event_user.uuid in user.event_uuids do
      true -> {:ok, event_user}
      _ -> {:error}
    end
  end
end
