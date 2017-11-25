defmodule Tower.OAuth2 do
  @moduledoc """
  Authorize resource and return Token
  """

  @grant_types Application.get_env(:tower, :grant_types, %{})

  def authorize(conn) do
    authorize(conn, conn.params)
  end
  def authorize(conn, params) do
    case strategy_check(params["grant_type"]) do
      {:error, msg} ->  {:error, msg}
      false -> {:error, "Strategy for '#{params["grant_type"]}' is not enabled!"}
      true  -> @grant_types[String.to_atom(params["grant_type"])].authorize(conn, params)
    end
  end

  defp strategy_check(nil), do: {:error, "Missing grant_type parameter"}
  defp strategy_check(grant_type) do
    Map.has_key?(@grant_types, String.to_atom(grant_type))
  end    
end
