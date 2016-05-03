defmodule FactsVsEvents.UserEvent do
  use FactsVsEvents.Web, :model

  schema "user_events" do
    field :uuid, :integer
    field :data, :map
    field :event_type, :string

    timestamps
  end

  @required_fields ~w(event_type)
  @optional_fields ~w(uuid)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
