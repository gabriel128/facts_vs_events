defmodule FactsVsEvents.Plugs.Authentication do
  @behaviour Plug
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  def init(opts), do: opts

  def call(conn, _opts) do
    # if conn.assigns.current_user do
    #   conn
    # else
      conn
      |> put_flash(:error, "You must be login to access that page.")
      |> redirect(to: "/event_user")
      |> halt()
    # end
  end
end
defmodule FactsVsEvents.Router do
  use FactsVsEvents.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :authenticated do
    plug FactsVsEvents.Plugs.Authentication, ""
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/users", FactsVsEvents do
    pipe_through [:browser, :authenticated]
    resources "/event_user", EventUserController
    resources "/fact_user", FactUserController
  end

  scope "/", FactsVsEvents do
    pipe_through :browser # Use the default browser stack
    get "/", HomeController, :index
  end
end
