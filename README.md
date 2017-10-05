# Tower

<p align="center" >
<img src="https://github.com/metismachine/tower/blob/master/tower.png?raw=true" alt="Tower" title="Tower">
</p>

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `tower` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tower, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/tower](https://hexdocs.pm/tower).

## Customizing Routes

In your routes file mount the oauth routes with:

``` use Tower.Routes ```

This will give you the following routes:

```
POST      oauth/access_tokens
resources oauth/applications
```

**Customize the path with passing in:**
```
use Tower.Routes, access_token: "oauth/token", applications: "oauth_app"
```

**Customize the controllers with:**
```
use Tower.Routes, controllers: [access_token: V1.Controllers.AccessToken, applications: V1.Controllers.Applications]
```

## Authenticating

**Resource Owner Password Credentials Flow**
By default the route will authorize the resource owner using:
```
Tower.OAuth.authorize(%{"email" => email, "password" => password, "client_id" => client_id, "grant_type" => "password", "scopes" => scopes})
```
Where the params:  
email      -> mandatory  
password   -> mandatory  
client_id  -> mandatory  
grant_type -> mandatory  
scopes     -> optional  



## Configuration

**Add your database configuration to the config file.**
```
config :tower, Tower.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "",
  password: "",
  database: "db",
  hostname: "localhost",
  pool_size: 10
```

**Set the Config Variables:**

```
config :tower, 
  ecto_repos: [Tower.Repo],
  repo: Tower.Repo,
  resource_owner: Application.Model.User,
  resource_owner_from_credentials: fn(params) ->    
    Tower.GrantType.Password.resource_owner_from_email_password(params)    
  end,
  grant_types: %{
    password: Tower.GrantType.Password
  },
  access_token_methods: [:from_bearer_authorization, :from_params, {Module, :get_access_token})]
```  

By default the resource owner is authenticated and retrieved using:
``` Tower.GrantType.Password.resource_owner_from_email_password(params)  ```
where params is %{email: email, password: password}

You can configure how the resource owner is retrieved by setting the resource_owner_from_credentials function within the config as shown above.  



## Authenticating Access Token

Call:  ``` Tower.Token.authenticate(conn, opts[:scopes])) ```
It will retrieve the access token based on the config variable "access_token_methods".  The default is "from_bearer_authorization" which gets the token from HTTP Header field, Authorization.  
You can configure it to get the access token from the "access_token" key in the query params or you can pass a tuple of Module and function to call.  The function needs to take the connection as an argument. 

It then validates the token checking that it is not expired, revoked, and has the necessary scopes.


## Plugs

### Authenticate

You can allow only authenticated requestors to access the resource using the plug: ``` Tower.Plug.Authenticate. ```
You can also pass in the required scopes necessary to access the resource and which actions to authenticate. 
The actions are limited by passing in either: `only` or `except` but not both.  The options can be a string or a list.
For this to work the connection must have a variable assigned for the action name.  `conn.private[:action_name]`.  

When authenticated, the access token is assigned to the connection assigns property as tower_token:  `conn.assigns.tower_token`

If you're using Plug.Router you could do something like this:

``` 
defmodule AppModule.Routers.User do

  plug :match
  plug Tower.Plug.Authenticate, scopes: ~w(read write), only: [:show]
  plug :dispatch

  get "/me", private: %{action_name: :show} do
    conn.assigns.tower_token
    |> show_user_response()
  end
  
  get "/all" do
    conn
    |> show_response()
  end
end

```

The route to "/me" will be authenticated and inside the function you will have access to the access token.  
The route to "/all"  wont be so anyone will be able to access it.  


### Unauthorized Only

Allow only access to a resource if the requestor isn't authenticated.

```plug Tower.Plug.UnauthorizedOnly```

