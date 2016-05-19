defmodule FactsVsEvents.RegistrationController do
  use FactsVsEvents.Web, :controller
  alias FactsVsEvents.LoginUser

  def new(conn, _params) do
    changeset = LoginUser.changeset(%LoginUser{})
    render conn, changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = LoginUser.changeset(%LoginUser{}, user_params)

    case FactsVsEvents.AuthService.register(changeset) do
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
