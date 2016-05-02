defmodule FactsVsEvents.UserEventsTest do
  use FactsVsEvents.ModelCase

  alias FactsVsEvents.UserEvents

  @valid_attrs %{data: %{}, event_type: "some content", uuid: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = UserEvents.changeset(%UserEvents{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = UserEvents.changeset(%UserEvents{}, @invalid_attrs)
    refute changeset.valid?
  end
end
