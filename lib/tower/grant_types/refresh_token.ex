defmodule Tower.GrantType.RefreshToken do

  @repo Application.get_env(:tower, :repo)
  @resource_owner Application.get_env(:tower, :resource_owner)

  alias Tower.Helpers.AccessToken, as: AccessTokenHelper

  def authorize(%{"refresh_token" => refresh_token, "client_id" => client_id, "client_secret" => client_secret}) do
    client = @repo.get_by(Tower.Models.OAuthApplication, uid: client_id, secret: client_secret)
    token = @repo.get_by(Tower.Models.AccessToken, refresh_token: refresh_token)
    
    validate_refresh_token(token)
    |> AccessTokenHelper.validate_client(client)
    |> create_access_token
    |> revoke_refresh_token(token)
  end

  def authorize(params) do
    reason = cond do
      params["client_id"] == nil -> "No client supplied"
      params["client_secret"] == nil -> "No client supplied"
      params["refresh_token"] == nil -> "No refresh_token supplied"
      true -> "Invalid Params"
    end
    {:error, reason}
  end

  def validate_refresh_token(nil), do: {:error, "Access Token is invalid"}
  def validate_refresh_token(token) do
    case is_nil(token.revoked_at) do 
      false -> {:error, "Access Token is invalid"}
      true ->  {:ok, token}
    end
  end

  def create_access_token(nil), do: {:error, "Invalid Client"}
  def create_access_token({:error, _} = msg), do: msg
  def create_access_token({:ok, refresh_token}) do
    scopes = Map.get(refresh_token.details, "scopes", "")
    token_params = %{
                      resource_owner_id: refresh_token.resource_owner_id,
                      application_id: refresh_token.application_id,
                      expires_in: Application.get_env(:tower, :expires_in, 7200),
                      scopes: scopes
                    }

    AccessTokenHelper.generate_token(token_params)
    |> AccessTokenHelper.insert_access_token(resource_owner_id: refresh_token.resource_owner_id, application_id: refresh_token.application_id, scopes: scopes, expires_in: token_params[:expires_in])
  end

  def revoke_refresh_token({:error, _} = msg, _), do: msg
  def revoke_refresh_token(new_token, refresh_token) do
    Tower.Models.AccessToken.revoke(refresh_token)
    new_token
  end
end
