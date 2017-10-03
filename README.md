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


