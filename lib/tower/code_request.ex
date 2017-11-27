defmodule Tower.CodeRequest do

  import Tower.Config, only: [repo: 0]

  alias Tower.Models.AccessGrant

  def authorize(nil, _), do: {:error, "Invalid Resource Owner"}
  def authorize(conn, resource_owner) do
    client = get_client(conn.params["client_id"])
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
    repo().insert(changeset)
  end

  def is_valid(_conn, nil, _), do: {:error, "Invalid Client ID"}
  def is_valid(_conn, client, %{"response_type" => _, "client_id" => _, "redirect_uri" => redirect_uri}) do
    if client.redirect_uri == redirect_uri do
      {:ok, true}
    else 
      {:error, "Invalid Redirect URI"}
    end
  end
  def is_valid(_conn, %{"response_type" => _, "client_id" => _}), do: {:error, "Missing redirect_uri"}

  defp get_client(nil), do: nil
  defp get_client(uid) do
    repo().get_by(Tower.Models.OAuthApplication, uid: uid)
  end
  defp build_query(conn, {:ok, grant}) do
    case conn.params["state"] do
      nil ->  
        %{code: grant.token}
      state ->
        %{code: grant.token, state: state}
    end
    
  end
  defp oauth_callback(conn, nil, query) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(400, Poison.encode_to_iodata!(query))
    |> Plug.Conn.halt()
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
