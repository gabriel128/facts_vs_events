defmodule FactsVsEvents.FakeLogin do
  alias FactsVsEvents.AuthService
  import Mock

  defmacro __using__(_opts) do
    quote do
      import FactsVsEvents.FakeLogin
    end
  end

  defmacro with_auth_mocked(do: block) do
    quote do
      with_mock AuthService, [logged_in?: fn (_) -> true end, 
       current_user: fn(_) -> %FactsVsEvents.User{} end] do 
         unquote(block)
       end
    end
  end
end
