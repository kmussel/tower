defmodule Tower.Plug.Authenticate do
  @moduledoc """
  Tower plug implementation to check authentications and
  to set access token -- conn.assigns.tower_token.
  """  
  import Plug.Conn
  import Keyword, only: [has_key?: 2]

  alias Tower.Token

  def init(opts), do: opts

  def call(conn, opts) do
    if action_valid?(conn, opts) do
      response_conn_with(conn, Token.authenticate(conn, opts[:scopes]))
    else
      conn
    end
  end

  defp response_conn_with(conn, {:ok, token}), do: assign(conn, :tower_token, token)
  defp response_conn_with(conn, {:error, reason}) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(:forbidden, Poison.encode_to_iodata!(%{error: reason}))
    |> Plug.Conn.halt()
  end

  defp action_valid?(conn, opts) do
    cond do
      has_key?(opts, :except) && has_key?(opts, :only) ->
        false
      has_key?(opts, :except) ->
        !action_exempt?(conn, opts)
      has_key?(opts, :only) ->
        action_included?(conn, opts)
      true ->
        true
    end
  end

  defp action_exempt?(conn, opts) do
    action = get_action(conn)

    if is_list(opts[:except]) && action in opts[:except] do
      true
    else
      action == opts[:except]
    end
  end

  defp action_included?(conn, opts) do
    action = get_action(conn)

    if is_list(opts[:only]) && action in opts[:only] do
      true
    else
      action == opts[:only]
    end
  end

  defp get_action(conn) do
    conn.private[:action_name]
  end
end
