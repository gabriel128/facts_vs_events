#TODO use bcrypt
defmodule FactsVsEvents.AuthService do
  alias FactsVsEvents.Repo
  alias FactsVsEvents.User
  import Ecto.Query, only: [from: 2]

  def register(user_changeset) do
    Ecto.Changeset.change(user_changeset, %{encrypted_password: encrypted_pass(user_changeset)})
    |> Repo.insert()
  end

  def login(changeset) do
    user = Repo.get_by(User, email: String.downcase(changeset.params["email"]), 
                             encrypted_password: encrypted_pass(changeset))
    login_response_regarding(user, changeset)
  end

  def current_user(conn) do
    id = Plug.Conn.get_session(conn, :current_user)
    fetch_current_user(id)
  end

  def logged_in?(conn), do: !!current_user(conn)

  defp fetch_current_user(nil) do
    false
  end

  defp fetch_current_user(id) do
    Repo.get(User, id)
  end

  defp login_response_regarding(nil, changeset) do
    {:error, changeset}
  end

  defp login_response_regarding(user, _) do
    {:ok, user}
  end

  defp encrypted_pass(changeset) do
    :crypto.hash(:sha256, changeset.params["password"]) |> Base.encode16
  end
end
