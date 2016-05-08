defmodule FactsVsEvents.ChangeUserCommand do
  alias FactsVsEvents.Repo
  alias FactsVsEvents.UserEventRepo
  alias FactsVsEvents.UserStateHandler
  alias FactsVsEvents.RepoResponseTransformer

  def execute(uuid, %{"email" => nil, "name" => _}),  do: {:error, "Missing email"}
  def execute(uuid, %{"email" => _, "name" => nil }),  do: {:error, "Missing name"}

  def execute(uuid, data) do
    Repo.insert(%FactsVsEvents.UserEvent{uuid: uuid, event_type: "UserChanged", data: Map.new(new_data_with(uuid, data))})
    |> RepoResponseTransformer.build_response()
  end

  defp new_data_with(uuid, data) do
    Enum.filter(data, fn {k,v} -> 
      existing_value?(k, v, event_user_by(uuid)) 
    end)
  end

  defp event_user_by(uuid) do
    UserEventRepo.find(uuid: uuid, with: UserStateHandler)
  end

  defp existing_value?(k, v, event_user) when is_atom(k) do
    Map.from_struct(event_user)[k] != v
  end

  defp existing_value?(k, v, event_user) do
    Map.from_struct(event_user)[String.to_atom(k)] != v
  end
end
