defmodule Formex.Ecto.Mixfile do
  use Mix.Project

  def project do
    [app: :formex_ecto,
     version: "0.2.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(),
     description: description(),
     docs: [main: "readme",
          extras: ["README.md", "guides.md"]],
     source_url: "https://github.com/jakub-zawislak/formex_ecto",
     elixirc_paths: elixirc_paths(Mix.env),
     aliases: aliases()
   ]
  end

  def application do
    []
  end

  defp deps do
    deps = [
      {:ecto, "~> 2.1"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:postgrex, ">= 0.0.0", only: [:dev, :test]}, # without a :dev the jakub-zawislak/phoenix-forms won't start. maybe should be removed
      {:phoenix, "~> 1.3.2", only: [:dev, :test]},
      {:phoenix_ecto, "~> 3.3", only: [:dev, :test]}
    ]

    if !System.get_env("FORMEX_DEV") do
      deps ++ [{:formex, ">= 0.6.6 and < 0.7.0"}]
      # deps ++ [{:formex, path: "../formex"}] # for tests with formex debugging
    else
      deps
    end
  end

  defp description do
    """
    Ecto integration for Formex form library
    """
  end

  defp package do
    [maintainers: ["Jakub Zawiślak"],
     licenses: ["MIT"],
     files: ~w(lib LICENSE.md mix.exs README.md),
     links: %{github: "https://github.com/jakub-zawislak/formex_ecto"}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    ["test": ["ecto.migrate", "test"]]
  end
end
