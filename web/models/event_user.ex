defmodule FactsVsEvents.Events.User do
  defstruct uuid: 0, name: "", email: ""
  # use FactsVsEvents.Web, :model

  # schema "event_users" do
  #   field :name, :string
  #   field :email, :string

  #   timestamps
  # end

  # @required_fields ~w()
  # @optional_fields ~w()

  # @doc """
  # Creates a changeset based on the `model` and `params`.

  # If no params are provided, an invalid changeset is returned
  # with no validation performed.
  # """
  # def changeset(model, params \\ :empty) do
  #   model
  #   |> cast(params, @required_fields, @optional_fields)
  # end
end
