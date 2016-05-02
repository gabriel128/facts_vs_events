defmodule FactsVsEvents.UserEvents do
  use FactsVsEvents.Web, :model

  schema "user_events" do
    field :uuid, :integer
    field :data, :map
    field :event_type, :string

    timestamps
  end

  @required_fields ~w(uuid data event_type)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
