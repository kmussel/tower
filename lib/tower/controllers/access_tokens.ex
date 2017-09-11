defmodule Tower.Controllers.AccessTokens do
  import Plug.Conn
  use Plug.Router

  plug :match
  plug :dispatch

  post "/" do
    conn
    |> authenticate_response()
  end

  match _ do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(:not_found, Poison.encode_to_iodata!(%{error: "#{conn.path_info} not found"}))
  end

  def authenticate_response(conn) do
    data = %{hello: "World"}
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(:ok, Poison.encode_to_iodata!(data))
    |> Plug.Conn.halt()
  end
end
