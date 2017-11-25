defmodule Tower.Controllers.Authorizations do
  import Plug.Conn
  use Plug.Router

  plug :match
  plug Tower.Plug.Authenticate
  plug :dispatch

  get "/" do
    conn
    |> Tower.CodeRequest.authorize(conn.assigns.current_resource_owner)
  end


  match _ do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(:not_found, Poison.encode_to_iodata!(%{error: "#{conn.path_info} not found"}))
  end
end
