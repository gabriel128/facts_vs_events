defmodule FactsVsEvents.UserEventRepo do
  alias FactsVsEvents.UserEvent
  alias FactsVsEvents.Repo
  import Ecto.Query, only: [from: 2]

  def uuids() do
    Repo.all(from e in UserEvent, distinct: e.uuid, select: e.uuid)
  end

  def get_events_for_user_with([uuid: uuid]) do
    Repo.all(from e in UserEvent, where: e.uuid == ^uuid)
  end
end
