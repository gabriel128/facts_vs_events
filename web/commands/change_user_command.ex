defmodule FactsVsEvents.ChangeUserCommand do
  alias FactsVsEvents.Repo
  alias FactsVsEvents.RepoResponseTransformer

  def execute(uuid, %{"email" => nil, "name" => _}),  do: {:error, "Missing email"}
  def execute(uuid, %{"email" => _, "name" => nil }),  do: {:error, "Missing name"}

  def execute(uuid, data) do
    Repo.insert(%FactsVsEvents.UserEvent{uuid: uuid, event_type: "UserChanged", data: data})
    |> RepoResponseTransformer.build_response()
  end

end
