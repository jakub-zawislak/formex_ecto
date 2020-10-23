use Mix.Config

config :formex_ecto, Formex.Ecto.TestRepo,
  username: "postgres",
  password: "postgres",
  database: "forms-test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "priv/test_repo"
