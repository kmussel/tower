defmodule Tower.Plug.Authenticate do
  @moduledoc """
  Authable plug implementation to check authentications and
  to set resouce owner.
  """  
  import Plug.Conn

  def init(opts) do
    Keyword.get opts, :scopes, ""
  end

  def call(conn, opts) do
    conn = put_private(conn, :my_app_opts, opts)    
    conn = assign(conn, :tower_token, "123456")
    conn
  end
end
