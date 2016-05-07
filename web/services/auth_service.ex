defmodule FactsVsEvents.AuthService do
  alias FactsVsEvents.Repo
  alias FactsVsEvents.User
  import Ecto.Query, only: [from: 2]

  def register(user_changeset, password) do
    Ecto.Changeset.change(user_changeset, %{encrypted_password: encrypted(password)})
    |> Repo.insert!()
  end

  def login(changeset, password) do
    user_changeset = changeset
    user = Repo.one(from u in User, 
                    where: u.email == ^user_changeset.params["email"]
                    and u.encrypted_password == ^encrypted(password))
    login_response_regarding(user, changeset)
  end

  defp login_response_regarding(nil, changeset) do
    {:error, changeset}
  end

  defp login_response_regarding(user, _) do
    {:ok, user}
  end

  defp encrypted(password) do
    :crypto.hash(:sha256, password) |> Base.encode16
  end
end
