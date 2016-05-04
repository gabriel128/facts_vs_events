defmodule FactsVsEvents.RepoResponseTransformer do
  def build_response({:ok, _ }), do: {:ok}
  def build_response({:error, _ }), do: {:error}
end
