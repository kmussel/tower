defmodule Tower.Token do
  import Plug.Conn

  alias Tower.Models.AccessToken
  alias Tower.Helpers.AccessToken, as: AccessTokenHelper

  import Tower.Config, only: [repo: 0]
  
  import Tower.Utils.Guards #, only: [access_token_methods: 0]

  def authenticate(conn, nil), do: authenticate(conn, [])
  def authenticate(conn, scopes) do
    conn
    |> retrieve_token()
    |> AccessTokenHelper.validate_token(scopes)
  end

  def revoke(nil, _), do: {:error, "Invalid Token"}
  def revoke(token, client_uid) do
    client = repo().get_by(Tower.Models.OAuthApplication, uid: client_uid)
    {:ok, token}
    |> AccessTokenHelper.validate_client(client)
    |> revoke_token()
  end  
  def revoke(nil), do: {:error, "Invalid Token"}
  def revoke(token) do
    revoke_token({:ok, token})
  end

  def revoke_token({:ok, token}) do
    case is_nil(token.revoked_at) do
      false -> {:ok, token}
      true -> AccessToken.revoke(token)
    end
  end
  def revoke_token({:error, _} = res), do: res

  def fetch_revoke_token(conn) do
    case conn.params["token_type_hint"] do
      "refresh_token" -> fetch_token_by(conn, "refresh_token") || fetch_token_by(conn, "access_token")
      _ ->  fetch_token_by(conn, "access_token") || fetch_token_by(conn, "refresh_token")
    end
  end

  defp fetch_token_by(conn, "refresh_token") do
    repo().get_by(AccessToken, refresh_token: conn.params["token"])
  end
  defp fetch_token_by(conn, _) do
    repo().get_by(AccessToken, token: conn.params["token"])
  end

  defp retrieve_token(conn, index \\ 0)
  defp retrieve_token(conn, index) when index < length(access_token_methods())  do
    case token_from_method(conn, index) do
      nil -> retrieve_token(conn, index+1)
      token -> repo().get_by(AccessToken, token: token) |> repo().preload(:resource_owner)
    end
  end
  defp retrieve_token(_, index) when index >= length(access_token_methods())  do
    nil
  end

  defp token_from_method(conn, index) do
    case Enum.at(access_token_methods(), index) do
      nil -> nil
      {module, func} -> apply(module, func, [conn])
      method -> parse_access_token(conn, method)
    end
  end

  defp parse_access_token(conn, method) when method == :from_bearer_authorization do 
    from_bearer_authorization(List.first(get_req_header(conn, "authorization")))    
  end
  defp parse_access_token(conn, method) when method == :from_params do 
    Map.get(conn.query_params, "access_token")
  end
  defp parse_access_token(_, _), do: nil

  
  defp from_bearer_authorization("Bearer " <> token), do: token
  defp from_bearer_authorization(_), do: nil
end
