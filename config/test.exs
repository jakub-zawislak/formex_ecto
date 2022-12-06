import Config

defmodule TestEnvironment do
  @database_name_suffix "_test"

  def get_database_url do
    url = System.get_env("DATABASE_URL")

    if is_nil(url) || String.ends_with?(url, @database_name_suffix) do
      url
    else
      raise "Expected database URL to end with '#{@database_name_suffix}', got: #{url}"
    end
  end
end

config :formex_ecto, Formex.Ecto.TestRepo,
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "priv/test_repo",
  url: TestEnvironment.get_database_url()

config :formex_ecto, ecto_repos: [Formex.Ecto.TestRepo]

config :formex,
  repo: Formex.Ecto.TestRepo,
  validator: Formex.Validator.Simple,
  translate_error: &Formex.Ecto.TestErrorHelpers.translate_error/1

config :logger, :console, level: :info
