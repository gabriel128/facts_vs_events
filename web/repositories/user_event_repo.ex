defmodule FactsVsEvents.Events.UserRepo do
  alias FactsVsEvents.Events.UserEvent
  alias FactsVsEvents.Repo
  import Ecto.Query, only: [from: 2]

  def uuids() do
    Repo.all(from e in UserEvent, distinct: e.uuid, select: e.uuid)
  end

  def insert(data) do
    Repo.insert(data)
  end

  def last_uuid() do
    Repo.one(from u in UserEvent, select: max(u.uuid)) || 0
  end

  def get_events_for_user_with([uuid: uuid]) do
    Repo.all(from e in UserEvent, where: e.uuid == ^uuid)
  end

  def find([uuid: uuid, with: state_handler]) do
    get_events_for_user_with(uuid: uuid)
    |> state_handler.current_state_from()
  end
end
