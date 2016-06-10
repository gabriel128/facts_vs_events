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

    resources "/event_user", EventUserGetController, only: [:index, :new, :edit, :show], as: :event_user
    resources "/event_user", EventUserTransformationController, only: [:create, :update, :delete], as: :event_user
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
