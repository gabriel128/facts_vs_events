defmodule FactsVsEvents.FactUser do
  use FactsVsEvents.Web, :model

  schema "fact_users" do
    field :name, :string
    field :email, :string
    field :uuid, :integer
    field :transaction_id, :integer
    field :at, Ecto.DateTime
    field :fact, :string
    field :commit_message, :string
  end

  @required_fields ~w(name email )
  @optional_fields ~w()
  # @optional_fields ~w(uuid transaction_id at fact commit_message)

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
