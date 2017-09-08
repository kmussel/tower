use Mix.Config

config :tower, Tower.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "argus",
  password: "",
  database: "metis_account",
  hostname: "localhost",
  pool_size: 10