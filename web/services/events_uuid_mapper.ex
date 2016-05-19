defmodule FactsVsEvents.EventsUuidMapper do
  alias FactsVsEvents.Repo

  def add_uuid_to_user(user, uuid) do
    uuids = user.event_uuids ++ [uuid]
    Ecto.Changeset.change(user, event_uuids: uuids)
    |> Repo.update()
  end
end
