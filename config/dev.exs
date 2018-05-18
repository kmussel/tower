use Mix.Config

config :tower, Tower.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("PG_USERNAME"),
  password: System.get_env("PG_PASSWORD"),
  database: "metis_account",
  hostname: "localhost",
  pool_size: 10
