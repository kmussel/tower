defmodule Tower.OAuth2 do
  @moduledoc """
  Authorize resource
  """

  @grant_types Application.get_env(:tower, :grant_types, %{})
  def authorize(params) do
    case strategy_check(params["grant_type"]) do 
      false -> {:error, "Strategy for '#{params["grant_type"]}' is not enabled!"}
      true  -> @grant_types[String.to_atom(params["grant_type"])].authorize(params)
    end
  end

  defp strategy_check(grant_type) do    
    Map.has_key?(@grant_types, String.to_atom(grant_type))
  end    
end
