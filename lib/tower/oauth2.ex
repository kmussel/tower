defmodule Tower.Oauth2 do
    @moduledoc """
    Authorize resource
    """  

    def authorize(params) do
    end

    def resource_owner_from_credentials(conn) do
      case Application.get_env(:tower, :resource_owner_from_credentials) do
        nil -> nil
        ro -> ro.(conn)
      end
    end
  end