defmodule Tower.CodeRequest do

  require IEx;
  @repo Application.get_env(:tower, :repo)


  alias Tower.Models.AccessGrant

  def authorize(nil, _), do: {:error, "Invalid Resource Owner"}
  def authorize(conn, resource_owner) do
    client = @repo.get_by(Tower.Models.OAuthApplication, uid: conn.params["client_id"])
    with {:ok, true} <- is_valid(conn, client, conn.params), 
         {:ok, grant} <- issue_access_grant(client, resource_owner, conn.params) do
          query = build_query(conn, {:ok, grant})

          conn
          |> oauth_callback(client, query)
    else
        {:error, msg} ->  
          query = %{error: "access_denied", error_description: msg}

          conn
          |> oauth_callback(client, query)
    end
  end

  def issue_access_grant(client, resource_owner, %{"redirect_uri" => redirect_uri} = params) do
    params = %{
      token: SecureRandom.hex(32),
      redirect_uri: redirect_uri,
      resource_owner_id: resource_owner.id,
      application_id: client.id,
      details: %{scopes: params["scopes"] || "" },
      expires_in: 480
    }
    
    changeset = AccessGrant.changeset(%AccessGrant{}, params)
    @repo.insert(changeset)
  end

  def is_valid(conn, nil, _), do: {:error, "Invalid Client ID"}
  def is_valid(conn, client, %{"response_type" => response_type, "client_id" => client_id, "redirect_uri" => redirect_uri}) do
    if client.redirect_uri == redirect_uri do
      {:ok, true}
    else 
      {:error, "Invalid Redirect URI"}
    end
  end
  def is_valid(conn, %{"response_type" => _, "client_id" => _}), do: {:error, "Missing redirect_uri"}

  defp build_query(conn, {:ok, grant}) do
    case conn.params["state"] do
      nil ->  
        %{code: grant.token}
      state ->
        %{code: grant.token, state: state}
    end
    
  end
  defp oauth_callback(conn, client, query) do
    querystr = URI.encode_query(query)
    url = "#{client.redirect_uri}?#{querystr}"
    conn
    |> Plug.Conn.put_resp_header("location", url)
    |> Plug.Conn.send_resp(301, "")
    |> Plug.Conn.halt()
  end
end
