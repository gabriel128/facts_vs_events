defmodule FactsVsEvents.FactRepo do
  alias FactsVsEvents.FactUser
  alias FactsVsEvents.Repo
  import Ecto.Query, only: [from: 2]
  
  def create(model, changeset, [commit_message: commit_message]) do
    last_uuid = Repo.one(from u in model, select: max(u.uuid)) || 0
    changes = %{transaction_id: 1, uuid: last_uuid + 1, fact: "created", at: Ecto.DateTime.utc, commit_message: commit_message} 
    Ecto.Changeset.change(changeset, changes) |> Repo.insert()
  end
end

defmodule FactsVsEvents.FactRepoTest do
  use FactsVsEvents.ModelCase
  alias FactsVsEvents.FactRepo
  alias FactsVsEvents.FactUser

  @valid_attrs %{email: "some content", name: "some content"}

  test "it creates FactUser with properties automatically set" do
    changeset = FactUser.changeset(%FactUser{}, %{name: "a_name", email: "an_email"})
    {:ok, record} = FactRepo.create(FactUser, changeset, commit_message: "Create a new user")
    fact_user = Repo.get!(FactUser, record.id)
    assert length(Repo.all(FactUser)) == 1
    assert fact_user.name == "a_name"
    assert fact_user.email == "an_email"
    assert fact_user.transaction_id == 1
    assert fact_user.uuid == 1
    assert fact_user.fact == "created"
    assert fact_user.at != nil
    assert fact_user.commit_message == "Create a new user"
  end
end
