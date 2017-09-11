defmodule Tower.Controllers.Applications do
  import Plug.Conn
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    conn
    |> response()
  end

  def response(conn) do
    data = %{hello: "application"}
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(:ok, Poison.encode_to_iodata!(data))
    |> Plug.Conn.halt()
  end

  match _ do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(:not_found, Poison.encode_to_iodata!(%{error: "#{conn.path_info} not found"}))
  end
end
