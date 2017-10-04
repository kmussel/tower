defmodule Tower.Helpers.AccessToken do

  @repo Application.get_env(:tower, :repo)
  @resource_owner Application.get_env(:tower, :resource_owner)
  @generator Application.get_env(:tower, :generator)

  alias Tower.Models.AccessToken

  def insert_access_token(nil, _), do: {:error, "Token could not be created"}
  def insert_access_token(token, resource_owner_id: resource_owner_id, application_id: application_id, scopes: scopes, expires_in: expires_in) do
    params = %{
      token: token,
      resource_owner_id: resource_owner_id,
      application_id: application_id,
      details: %{scopes: scopes},
      expires_in: expires_in
    }
    params = case Application.get_env(:tower, :use_refresh_token, false) do
        false -> params
        true ->  Map.put(params, :refresh_token, SecureRandom.hex(32))
    end
    changeset = Tower.Models.AccessToken.changeset(%Tower.Models.AccessToken{}, params)
    @repo.insert(changeset)
  end

  def generate_token(params) do
    case @generator do
      nil -> SecureRandom.hex(32)
      generator -> generator.generate(params)
    end
  end

  def validate_client(_, nil), do: {:error, "Client ID is invalid"}
  def validate_client({:error, _} = res, _), do: res
  def validate_client({:ok, _} = res, client = %Tower.Models.OAuthApplication{}) do
    validate_client(res, client.id)
  end
  def validate_client({:ok, token}, client_id) do
    case token.application_id == client_id do
      true ->  {:ok, token}
      false -> {:error, "Client ID is invalid"}
    end
  end

  def validate_token(token, scopes \\ [])
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

end
