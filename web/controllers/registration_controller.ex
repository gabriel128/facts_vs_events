defmodule FactsVsEvents.RegistrationController do
  use FactsVsEvents.Web, :controller
  alias FactsVsEvents.LoginUser

  def new(conn, _params) do
    changeset = LoginUser.changeset(%LoginUser{})
    render conn, changeset: changeset
  end

  def create(conn, %{"login_user" => user_params}) do
    LoginUser.changeset(%LoginUser{}, user_params)
    |> FactsVsEvents.AuthService.register()
    |> case do 
        {:ok, user} ->
          conn
          |> put_session(:current_user, user.id)
          |> put_flash(:info, "Your account was created")
          |> redirect(to: "/")
        {:error, changeset} ->
          conn
          |> put_flash(:info, "Unable to create account")
          |> render("new.html", changeset: changeset)
      end
  end
end
