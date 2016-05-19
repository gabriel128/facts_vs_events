defmodule FactsVsEvents.FactUserTest do
  use FactsVsEvents.ModelCase

  alias FactsVsEvents.Fact.User

  @valid_attrs %{email: "some content", name: "some content", owner_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
