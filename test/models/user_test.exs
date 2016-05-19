defmodule FactsVsEvents.LoginUserTest do
  use FactsVsEvents.ModelCase

  alias FactsVsEvents.LoginUser
  alias FactsVsEvents.Repo
  alias FactsVsEvents.AuthService

  @valid_attrs %{email: "some@content", password: "password"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = LoginUser.changeset(%LoginUser{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = LoginUser.changeset(%LoginUser{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "register a new user" do
    changeset = LoginUser.changeset(%LoginUser{}, @valid_attrs)
    AuthService.register(changeset)
    user = Repo.one(LoginUser)
    assert user.encrypted_password == :crypto.hash(:sha256, "password") |> Base.encode16
  end

  test "authentication of existing user successfull" do
    changeset = LoginUser.changeset(%LoginUser{}, @valid_attrs)
    AuthService.register(changeset)
    {:ok, user} = AuthService.login(changeset)
    assert user.email == "some@content"
  end

  test "authentication of existing user unsuccessfull" do
    changeset = LoginUser.changeset(%LoginUser{}, %{email: "some@mail", password: "password"})
    AuthService.register(changeset)
    changeset = LoginUser.changeset(%LoginUser{}, %{email: "some@mail", password: "passworde"})
    {:error, user_changeset} = AuthService.login(changeset)
    assert user_changeset.params["email"] == "some@mail"
  end
end
