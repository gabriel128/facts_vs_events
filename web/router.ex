defmodule FactsVsEvents.Router do
  use FactsVsEvents.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FactsVsEvents do
    pipe_through :browser # Use the default browser stack

    get "/", HomeController, :index
    resources "/fact_user", FactUserController
    resources "/event_user", EventUserController
  end

  # Other scopes may use custom stacks.
  # scope "/api", FactsVsEvents do
  #   pipe_through :api
  # end
end
