defmodule FactsVsEvents.Events.UserValidator do
  def validate(%{name: nil, email: nil}), do: {:error, "Missing attributes"}
  def validate(%{email: nil, name: _}),  do: {:error, "Missing email"}
  def validate(%{name: nil, email: _}),  do: {:error, "Missing name"}

  def validate(%{"name" => nil, "email" => nil}), do: {:error, "Missing attributes"}
  def validate(%{"email" => nil, "name" => _}),  do: {:error, "Missing email"}
  def validate(%{"name" => nil, "email" => _}),  do: {:error, "Missing name"}
  def validate(_), do: {:ok}
end
