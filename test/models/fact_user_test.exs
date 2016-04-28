defmodule FactsVsEvents.FactUserTest do
  use FactsVsEvents.ModelCase

  alias FactsVsEvents.FactUser

  @valid_attrs %{commit_message: "some content", date: "2010-04-17 14:00:00", email: "some content", fact: "some content", name: "some content", transaction_id: 42, uuid: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = FactUser.changeset(%FactUser{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = FactUser.changeset(%FactUser{}, @invalid_attrs)
    refute changeset.valid?
  end
end
