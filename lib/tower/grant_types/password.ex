defmodule Tower.GrantType.Password do
  @moduledoc """
  Password grant type for OAuth2 Authorization Server
  """
  alias Comeonin.Bcrypt

  @repo Application.get_env(:tower, :repo)
  @resource_owner Application.get_env(:tower, :resource_owner)
  @generator Application.get_env(:tower, :generator)

  
  def authorize(%{"email" => email, "password" => password, "client_id" => client_id, "scopes" => scopes}) do
    client = @repo.get_by(Tower.Models.OAuthApplication, uid: client_id)
    owner = resource_owner_from_credentials(%{"email" => email, "password" => password})
    create_access_token(client, owner, scopes)
  end

  def authorize(%{"email" => _, "password" => _, "client_id" => _} = params) do
    params = Map.put(params, "scopes", "")
    authorize(params)
  end

  def authorize(params) do
    reason = cond do
      params["email"] == nil -> "No email supplied"
      params["password"] == nil -> "No password supplied"
      params["client_id"] == nil -> "No client id supplied"
      true -> "Invalid Params"
    end
    {:error, reason}
  end

  defp match_with_user_password(nil, _), do: {:error, "Resource Owner Not Found"}
  defp match_with_user_password(user, password) do
    if Bcrypt.checkpw(password, Map.get(user, :password, "")) do
      {:ok, user}
    else
      {:error, "Invalid Password"}
    end
  end

  def resource_owner_from_credentials(params) do
    case Application.get_env(:tower, :resource_owner_from_credentials) do
      nil -> resource_owner_from_email_password(params)
      ro -> ro.(params)
    end
  end

  def resource_owner_from_email_password(%{"email" => email, "password" => password}) do
    @repo.get_by(@resource_owner, email: email)
    |> match_with_user_password(password)
  end
  def resource_owner_from_email_password(_), do: {:error, "Invalid Params"}

  def create_access_token(client, owner_tuple, scopes \\ "")
  def create_access_token(_, {:error, reason}, _), do: {:error, reason}
  def create_access_token(nil, _, _), do: {:error, "Invalid Client"}
  def create_access_token(client, {:ok, owner}, scopes) do
    token_params = %{
                      resource_owner_id: owner.id,
                      application: client,
                      expires_in: Application.get_env(:tower, :expires_in, 7200),
                      scopes: scopes
                    }

    generate_token(token_params)
    |> insert_access_token(resource_owner_id: owner.id, application_id: client.id, scopes: scopes, expires_in: token_params[:expires_in])
  end

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
end
