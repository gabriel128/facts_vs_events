defmodule FactsVsEvents.UserTest do
  use FactsVsEvents.ModelCase

  alias FactsVsEvents.User
  alias FactsVsEvents.Repo
  alias FactsVsEvents.AuthService

  @valid_attrs %{email: "some content", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "register a new user" do
    changeset = User.changeset(%User{}, @valid_attrs)
    AuthService.register(changeset, "password")
    user = Repo.one(User)
    assert user.encrypted_password == :crypto.hash(:sha256, "password") |> Base.encode16
  end

  test "authentication of existing user successfull" do
    changeset = User.changeset(%User{}, @valid_attrs)
    AuthService.register(changeset, "password")
    {:ok, user} = AuthService.login(changeset, "password")
    assert user.name == "some content"
  end

  test "authentication of existing user unsuccessfull" do
    changeset = User.changeset(%User{}, @valid_attrs)
    AuthService.register(changeset, "password")
    {:error, user_changeset} = AuthService.login(changeset, "passworde")
    assert user_changeset.params["name"] == "some content"
  end
end
