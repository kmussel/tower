defmodule Tower.OAuth2 do
    @moduledoc """
    Authorize resource
    """  

    @grant_types Application.get_env(:tower, :grant_types)
    def authorize(params) do
      @grant_types[String.to_atom(params["grant_type"])].authorize(params)
    end
  end
