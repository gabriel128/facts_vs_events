defmodule FactsVsEvents.Plugs.Authentication do
  @behaviour Plug
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  import FactsVsEvents.AuthService, only: [current_user: 1, logged_in?: 1]

  def init(opts), do: opts

  def call(conn, _opts) do
    logged_in?(conn)
    |> respond_with(conn)
  end

  defp respond_with(true, conn) do
    conn
  end

  defp respond_with(_,  conn) do
    conn
    |> put_flash(:error, "You must login to access.")
    |> redirect(to: "/login")
    |> halt()
  end
end
