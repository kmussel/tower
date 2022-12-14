defmodule Tower.Routes do

  defmacro __using__(params) do
    quote location: :keep do
      require Plug.Router
      require Tower.Utils.Router
      import Plug.Conn

      import unquote(__MODULE__)

      plug Plug.Parsers, 
        parsers: [:urlencoded, :multipart, :json],
        pass: ["*/*"],
        json_decoder: Poison
      
      opts = unquote(params)

      access_token = Keyword.get(opts, :access_token, "oauth/access_tokens")
      applications = Keyword.get(opts, :applications, "oauth/applications")
      authorization = Keyword.get(opts, :authorizations, "oauth/authorize")
      
      controllers = Keyword.get(opts, :controllers, [])
      access_tokens_controller = Keyword.get(controllers, :access_token, Tower.Controllers.AccessTokens)
      applications_controller = Keyword.get(controllers, :authorization, Tower.Controllers.Applications)
      authorizations_controller = Keyword.get(controllers, :authorization, Tower.Controllers.Authorizations)

      Tower.Utils.Router.forward access_token,      to: access_tokens_controller
      Tower.Utils.Router.forward applications,      to: applications_controller
      Tower.Utils.Router.forward authorization,     to: authorizations_controller
    end
  end
end
