use Mix.Config

config :formex_ecto, ecto_repos: [Formex.Ecto.TestRepo]

config :formex,
  repo: Formex.Ecto.TestRepo,
  validator: Formex.Validator.Simple,
  translate_error: &Formex.Ecto.TestErrorHelpers.translate_error/1

config :logger, :console,
  level: :info

import_config "test.secret.exs"
