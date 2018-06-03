use Mix.Config

config :formex_ecto, Formex.Ecto.TestRepo,
  # postgres is required for schema_embedded tests
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "forms-test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "priv/test_repo"
