defmodule FactsVsEvents.EventUserTest do
  use FactsVsEvents.ModelCase

  alias FactsVsEvents.EventUser

  @valid_attrs %{email: "some content", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = EventUser.changeset(%EventUser{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = EventUser.changeset(%EventUser{}, @invalid_attrs)
    refute changeset.valid?
  end
end
