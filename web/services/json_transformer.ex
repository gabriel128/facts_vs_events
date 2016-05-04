defmodule FactsVsEvents.JsonTransformer do
  def keys_to_atoms(map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
  end
end
