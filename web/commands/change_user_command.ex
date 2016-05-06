defmodule FactsVsEvents.ChangeUserCommand do
  alias FactsVsEvents.Repo
  alias FactsVsEvents.UserEventRepo
  alias FactsVsEvents.UserStateHandler
  alias FactsVsEvents.RepoResponseTransformer

  def execute(uuid, %{"email" => nil, "name" => _}),  do: {:error, "Missing email"}
  def execute(uuid, %{"email" => _, "name" => nil }),  do: {:error, "Missing name"}

  def execute(uuid, data) do
    event_user = UserEventRepo.get_events_for_user_with(uuid: uuid) 
                 |> UserStateHandler.current_state_from()
    new_data = Enum.filter(data, fn {k,v} -> 
      existing_value?(k, v, event_user)
    end)
    Repo.insert(%FactsVsEvents.UserEvent{uuid: uuid, event_type: "UserChanged", 
      data: Map.new(new_data)})
    |> RepoResponseTransformer.build_response()
  end

  defp existing_value?(k, v, event_user) when is_atom(k) do
    Map.from_struct(event_user)[k] != v 
  end

  defp existing_value?(k, v, event_user) do
    Map.from_struct(event_user)[String.to_atom(k)] != v 
  end

end
