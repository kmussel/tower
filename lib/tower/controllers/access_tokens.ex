defmodule Tower.Controllers.AccessTokens do
  import Plug.Conn
  use Plug.Router

  plug :match
  plug :dispatch

  post "/" do
    conn.params
    |> Tower.OAuth2.authorize()
    |> handle_authorization(conn)
  end

  match _ do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(:not_found, Poison.encode_to_iodata!(%{error: "#{conn.path_info} not found"}))
  end

  defp handle_authorization(res, conn) do
    case res do
      {:ok, token} ->
        data = Map.take(token, [:id, :token, :expires_in, :inserted_at, :refresh_token])
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(:ok, Poison.encode_to_iodata!(data))
        |> Plug.Conn.halt()
      {:error, reason} ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(:unprocessable_entity, Poison.encode_to_iodata!(%{error: reason}))
        |> Plug.Conn.halt()
    end
  end
end
