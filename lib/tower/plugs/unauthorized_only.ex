defmodule Tower.Plug.UnauthorizedOnly do
  @moduledoc """
  Tower plug implementation to refute authencated users to access resources.
  """

  import Plug.Conn

  alias Tower.Token

  def init([]), do: false

  @doc """
  Plug function to refute authencated users to access resources.

  ## Examples

      defmodule AnyModule.AppController do
        plug Tower.Plug.UnauthorizedOnly
        plug :dispatch

        post "/register" do
          # only not logged in user can access this action
        end
      end
  """
  def call(conn, _opts) do
    response_conn_with(conn, Token.authenticate(conn, []))
  end

  defp response_conn_with(conn, {:ok, _}) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(:forbidden, Poison.encode_to_iodata!(%{error: "Only unauhorized access allowed!"}))
    |> Plug.Conn.halt()
  end
  defp response_conn_with(conn, _), do: conn
end
