# Formex Ecto

Library that integrates Ecto with Formex.

It also has an Ecto.Changeset validator adapter for those who want to easily migrate a project
from old (< 0.5) Formex.

# Instalation

```elixir
def deps do
  [{:formex_ecto, "~> 0.1.0"}]
end
```

`config/config.exs`
```elixir
config :formex,
  repo: App.Repo
```

`web/web.ex`
```elixir
def controller do
  quote do
    use Formex.Ecto.Controller
  end
end
```

In every form type that uses Ecto:

```elixir
defmodule App.ArticleType do
  use Formex.Type
  use Formex.Ecto.Type
```

# Docs

* [Usage in a controller](https://hexdocs.pm/formex_ecto/Formex.Ecto.Controller.html)
* [Changeset validator adapter](https://hexdocs.pm/formex_ecto/Formex.Ecto.ChangesetValidator.html)