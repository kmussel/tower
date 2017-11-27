defmodule Tower.GrantType.Password do
  @moduledoc """
  Password grant type for OAuth2 Authorization Server
  """
  alias Comeonin.Bcrypt
  alias Tower.Helpers.AccessToken, as: AccessTokenHelper

  import Tower.Config, only: [repo: 0, resource_owner: 0]

  def authorize(conn, %{"email" => _, "password" => _, "scopes" => scopes} = params) do
    client =
      case is_nil(params["client_id"]) do
        true -> nil
        false -> repo().get_by(Tower.Models.OAuthApplication, uid: params["client_id"])
      end
    owner = resource_owner_from_credentials(conn, client)
    create_access_token(client, owner, scopes)
  end

  def authorize(conn, %{"email" => _, "password" => _, "client_id" => _} = params) do
    params = Map.put(params, "scopes", "")
    authorize(conn, params)
  end

  def authorize(_conn, params) do
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

  def resource_owner_from_credentials(conn, client) do
    case Application.get_env(:tower, :resource_owner_from_credentials) do
      nil -> resource_owner_from_email_password(conn.params)
      ro -> apply(ro, :resource_owner_from_credentials, [conn, client])
    end
  end

  def resource_owner_from_email_password(%{"email" => email, "password" => password}) do
    repo().get_by(resource_owner(), email: email)
    |> match_with_user_password(password)
  end
  def resource_owner_from_email_password(_), do: {:error, "Invalid Params"}

  def create_access_token(client, owner_tuple, scopes \\ "")
  def create_access_token(_, {:error, reason}, _), do: {:error, reason}
  def create_access_token(client, {:ok, owner}, scopes) do
    client_id = 
      case is_nil(client) do
        true -> nil
        false -> client.id
      end
    token_params = %{
                      resource_owner_id: owner.id,
                      application: client,
                      expires_in: Application.get_env(:tower, :expires_in, 7200),
                      scopes: scopes
                    }

    AccessTokenHelper.generate_token(token_params)
    |> AccessTokenHelper.insert_access_token(resource_owner_id: owner.id, application_id: client_id, scopes: scopes, expires_in: token_params[:expires_in])
  end
end
