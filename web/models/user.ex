defmodule FactsVsEvents.LoginUser do
  use FactsVsEvents.Web, :model

  schema "users" do
    field :name, :string
    field :encrypted_password, :string
    field :email, :string
    field :event_uuids, {:array, :integer}, default: []

    field :password, :string, virtual: true
    timestamps
  end

  @required_fields ~w(email password)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 4)
  end
end
