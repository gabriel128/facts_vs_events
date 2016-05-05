defmodule FactsVsEvents.CreateUserCommand do
  alias FactsVsEvents.Repo
  alias FactsVsEvents.RepoResponseTransformer
  alias FactsVsEvents.UserEvent
  import Ecto.Query, only: [from: 2]

  def execute(%{email: nil}),  do: {:error, "Missing email"}
  def execute(%{name: nil}),  do: {:error, "Missing name"}

  def execute(%{name: _ , email: _ } = data) do
    last_uuid = Repo.one(from u in UserEvent, select: max(u.uuid)) || 0
    Repo.insert(%UserEvent{uuid: last_uuid + 1, event_type: "UserCreated", data: data})
    |> RepoResponseTransformer.build_response()
  end
end

