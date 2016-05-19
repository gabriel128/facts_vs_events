defmodule FactsVsEvents.Events.CommandResponseTransformer do
  def build_response({:ok, _ }), do: {:ok}
  def build_response({:error, _ }), do: {:error}

  def build_response_with_uuid({:ok, _ }, uuid), do: {:ok, uuid + 1}
  def build_response_with_uuid({:error, _ }, uuid), do: {:error, uuid}
end
