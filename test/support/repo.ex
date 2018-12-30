defmodule Formex.Ecto.TestRepo do
  use Ecto.Repo,
    otp_app: :formex_ecto,
    # postgres is required for schema_embedded tests
    adapter: Ecto.Adapters.Postgres
end
