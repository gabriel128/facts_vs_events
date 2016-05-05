defmodule FactsVsEvents.EventUserView do
  use FactsVsEvents.Web, :view

  def html_safe_map(data) when is_map(data) do
    as_string = Enum.reduce(Map.keys(data), [], fn (key, acc) -> 
                  acc ++ ["#{key}: #{data[key]}"] 
                end) 
                |> Enum.join(", ")
    "{#{as_string}}"
  end

  def html_safe_map(_) do
    "{}"
  end

end
