# Tower

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
