defmodule FactsVsEvents.FakeLogin do
  alias FactsVsEvents.AuthService
  alias FactsVsEvents.User
  import Mock

  defmacro __using__(_opts) do
    quote do
      import FactsVsEvents.FakeLogin
    end
  end

  defmacro with_auth_mocked(user, do: block) do
    quote do
      with_mock AuthService, [logged_in?: fn (_) -> true end, 
       current_user: fn(_) -> unquote(user) end] do 
         unquote(block)
       end
    end
  end

  defmacro with_auth_mocked(do: block) do
    quote do
      with_mock AuthService, [logged_in?: fn (_) -> true end, 
       current_user: fn(_) -> %{id: 1, email: "some@mail", name: "some", event_uuids: []} end] do 
         unquote(block)
       end
    end
  end
end
