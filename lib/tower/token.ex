defmodule Tower.Token do
  import Plug.Conn

  alias Tower.Models.AccessToken
  
  @repo Application.get_env(:tower, :repo)
  @access_token_methods Application.get_env(:tower, :access_token_methods, [:from_bearer_authorization])

  def authenticate(conn, nil), do: authenticate(conn, [])
  def authenticate(conn, scopes) do
    conn
    |> retrieve_token()
    |> validate_token(scopes)    
  end

  def validate_token(nil, _), do: {:error, "Access Token is invalid"}
  def validate_token(token, scopes) do
    case is_valid(token, scopes) do 
      false -> {:error, "Access Token is invalid"}
      true ->  {:ok, token}
    end
  end

  def is_valid(nil, _), do: false 
  def is_valid(token, scopes) do 
    !AccessToken.is_expired?(token) && is_nil(token.revoked_at) && AccessToken.has_scopes(token, scopes)
  end

  def retrieve_token(conn, index \\ 0)
  def retrieve_token(conn, index) when index < length(@access_token_methods)  do
    case token_from_method(conn, index) do
      nil -> retrieve_token(conn, index+1)
      token -> @repo.get_by(Tower.Models.AccessToken, token: token) |> @repo.preload(:resource_owner)
    end
  end
  def retrieve_token(_, index) when index >= length(@access_token_methods)  do
    nil
  end

  defp token_from_method(conn, index) do
    case Enum.at(@access_token_methods, index) do
      nil -> nil
      {module, func} -> apply(module, func, [conn])
      method -> parse_access_token(conn, method)
    end
  end

  defp parse_access_token(conn, method) when method == :from_bearer_authorization do 
    from_bearer_authorization(List.first(get_req_header(conn, "authorization")))    
  end
  defp parse_access_token(conn, method) when method == :from_params do 
    conn.query_params["access_token"]
  end
  defp parse_access_token(_, _), do: nil

  
  defp from_bearer_authorization("Bearer " <> token), do: token
  defp from_bearer_authorization(_), do: nil
end
