defmodule Tower.GrantType.AuthorizationCode do

  require IEx;
  @repo Application.get_env(:tower, :repo)

  alias Tower.Helpers.AccessToken, as: AccessTokenHelper

  def authorize(_conn, %{"code" => auth_code, "client_id" => client_id, "client_secret" => client_secret}) do
    client = @repo.get_by(Tower.Models.OAuthApplication, uid: client_id, secret: client_secret)
    grant = @repo.get_by(Tower.Models.AccessGrant, token: auth_code)

    validate_grant_code(grant)
    |> AccessTokenHelper.validate_client(client)
    |> create_access_token
    |> revoke_grant(grant)
  end

  def authorize(_conn, params) do
    reason = cond do
      params["client_id"] == nil -> "No client supplied"
      params["client_secret"] == nil -> "No client supplied"
      params["code"] == nil -> "No authorization code supplied"
      true -> "Invalid Params"
    end
    {:error, reason}
  end

  def validate_grant_code(nil), do: {:error, "Access Grant is invalid"}
  def validate_grant_code(grant) do
    case is_nil(grant.revoked_at) do 
      false -> {:error, "Access Grant is invalid"}
      true ->  {:ok, grant}
    end
  end

  def create_access_token(nil), do: {:error, "Invalid Client"}
  def create_access_token({:error, _} = msg), do: msg
  def create_access_token({:ok, grant}) do
    scopes = Map.get(grant.details, "scopes", "")
    token_params = %{
                      resource_owner_id: grant.resource_owner_id,
                      application_id: grant.application_id,
                      expires_in: Application.get_env(:tower, :expires_in, 7200),
                      scopes: scopes
                    }

    AccessTokenHelper.generate_token(token_params)
    |> AccessTokenHelper.insert_access_token(resource_owner_id: grant.resource_owner_id, application_id: grant.application_id, scopes: scopes, expires_in: token_params[:expires_in])
  end

  def revoke_grant({:error, _} = msg, _), do: msg
  def revoke_grant(access_token, grant) do
    Tower.Models.AccessGrant.revoke(grant)
    access_token
  end
end
