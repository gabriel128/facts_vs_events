defmodule FactsVsEvents.Plugs.Authentication do
  @behaviour Plug
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  import FactsVsEvents.AuthService, only: [current_user: 1, logged_in?: 1]

  def init(opts), do: opts

  def call(conn, _opts) do
    case logged_in?(conn) do
      true -> conn
      _ ->
          conn
          |> put_flash(:error, "You must be login to access that page.")
          |> redirect(to: "/login")
          |> halt()
    end
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

    resources "/registration", RegistrationController, only: [:new, :create]

    get    "/login",  SessionController, :new
    post   "/login",  SessionController, :create
    delete "/logout", SessionController, :delete
  end
end
