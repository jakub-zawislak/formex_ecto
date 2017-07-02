use Mix.Config

config :formex_ecto, Formex.Ecto.TestRepo,
  adapter: Ecto.Adapters.Postgres, # postgres is required for schema_embedded tests
  username: "postgres",
  password: "postgres",
  database: "forms-test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "priv/test_repo"
