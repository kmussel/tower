defmodule Tower.Plug.Authenticate do
  @moduledoc """
  Tower plug implementation to get authenticated resource
  """  
  import Plug.Conn
  import Keyword, only: [has_key?: 2]

  alias Tower.Token

  def init(opts), do: opts

  def call(conn, opts) do
    if action_valid?(conn, opts) do
      authenticate_resource_owner(conn)
    else
      conn
    end
  end

  defp authenticate_resource_owner(conn) do
    case Application.get_env(:tower, :resource_owner_authenticator) do
      nil -> conn
      ro ->
        apply(ro, :resource_owner_authenticator, [conn])
        |> set_resource_owner(conn)
    end
  end

  defp set_resource_owner(resource_owner, conn) do
    assign(conn, :current_resource_owner, resource_owner)
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
