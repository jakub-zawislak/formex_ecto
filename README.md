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
def model do
  quote do
    use Formex.Ecto.Schema
  end
end

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
  use Formex.Ecto.Type # <- add this
```

## Optional Ecto.Changeset validator

`config/config.exs`
```elixir
config :formex,
  validator: Formex.Ecto.ChangesetValidator
```

[More info about this validator](https://hexdocs.pm/formex_ecto/Formex.Ecto.ChangesetValidator.html)

# Usage

## Model

We have models Article, Category and Tag:

```elixir
schema "articles" do
  field :title, :string
  field :content, :string
  field :hidden, :boolean

  belongs_to :category, App.Category
  many_to_many :tags, App.Tag, join_through: "articles_tags" #...
end
```

```elixir
schema "categories" do
  field :name, :string
end
```

```elixir
schema "tags" do
  field :name, :string
end
```

## Form Type

Let's create a form for Article using Formex. For validation we will use
[Ecto.Changeset validator](https://hexdocs.pm/formex_ecto/Formex.Ecto.ChangesetValidator.html)
```elixir
# /web/form/article_type.ex
defmodule App.ArticleType do
  use Formex.Type
  alias Formex.Ecto.CustomField.SelectAssoc

  def build_form(form) do
    form
    |> add(:title, :text_input, label: "Title", validation: [:required])
    |> add(:content, :textarea, label: "Content", phoenix_opts: [
      rows: 4
    ], validation: [:required])
    |> add(:category_id, SelectAssoc, label: "Category", phoenix_opts: [
      prompt: "Choose a category"
    ], validation: [:required])
    |> add(:tags, SelectAssoc, label: "Tags", validation: [:required])
    |> add(:hidden, :checkbox, label: "Is hidden?", required: false)
    |> add(:save, :submit, label: "Submit", phoenix_opts: [
      class: "btn-primary"
    ])
  end
end
```

## Controller

```elixir
def new(conn, _params) do
  form = create_form(App.ArticleType, %Article{})
  render(conn, "new.html", form: form)
end

def create(conn, %{"article" => article_params}) do
  App.ArticleType
  |> create_form(%Article{}, article_params)
  |> insert_form_data
  |> case do
    {:ok, _article} ->
      conn
      |> put_flash(:info, "Article created successfully.")
      |> redirect(to: article_path(conn, :index))
    {:error, form} ->
      render(conn, "new.html", form: form)
  end
end

def edit(conn, %{"id" => id}) do
  article = Repo.get!(Article, id)
  form = create_form(App.ArticleType, article)
  render(conn, "edit.html", article: article, form: form)
end

def update(conn, %{"id" => id, "article" => article_params}) do
  article = Repo.get!(Article, id)

  App.ArticleType
  |> create_form(article, article_params)
  |> update_form_data
  |> case do
    {:ok, article} ->
      conn
      |> put_flash(:info, "Article updated successfully.")
      |> redirect(to: article_path(conn, :show, article))
    {:error, form} ->
      render(conn, "edit.html", article: article, form: form)
  end
end
```

## Template

`form.html.eex`
```elixir
<%= formex_form_for @form, @action, fn f -> %>
  <%= if @form.submitted? do %>Oops, something went wrong!<% end %>

  <%= formex_row f, :name %>
  <%= formex_row f, :content %>
  <%= formex_row f, :category_id %>
  <%= formex_row f, :tags %>
  <%= formex_row f, :hidden %>
  <%= formex_row f, :save %>

  <%# or generate all fields at once: formex_rows f %>
<% end %>
```

Also replace `changeset: @changeset` with `form: @form` in `new.html.eex` and `edit.html.eex`

The final effect after submit:

<img src="http://i.imgur.com/ojyrWJA.png" width="511px">

# Collections of forms

Every schema used in collections of forms should call `formex_collection_child`:

```elixir
schema "user_addresses" do
  field       :street, :string
  field       :postal_code, :string
  field       :city, :string
  belongs_to  :user, App.User

  formex_collection_child() # <- add this
end
```

This macro adds `:formex_id` and `:formex_delete` virtual fields.

# Automation

This library does few things automatically.

## Nested forms and collections

```elixir
def build_form(form) do
  form
  |> add(:user_info, App.UserInfoType, struct_module: App.UserInfo)
end
```

You don't need to pass `:struct_module` option, it is taken from schema information.

## Method

```elixir
<%= formex_form_for @form, article_path(@conn, :create), [method: :post], fn f -> %>
```

You don't need to pass `:method` option, it's set basing on `struct.id` value.

# Tests

## Test database
Use `config/test.secret.example.exs` to create `config/test.secret.exs`

Run this command to migrate:
```bash
MIX_ENV=test mix ecto.migrate -r Formex.Ecto.TestRepo
```
Now you can use tests via `mix test`.

## Creating a new migration
```bash
MIX_ENV=test mix ecto.gen.migration migration_name -r Formex.Ecto.TestRepo
```

# Docs

* [Controller](https://hexdocs.pm/formex_ecto/Formex.Ecto.Controller.html) - controller helpers
* [Form Type](https://hexdocs.pm/formex_ecto/Formex.Ecto.Type.html) - changeset modification
* [Changeset validator adapter](https://hexdocs.pm/formex_ecto/Formex.Ecto.ChangesetValidator.html) -
  validation using Ecto.Changeset, adding errors to a changeset

## Custom fields
* [SelectAssoc](https://hexdocs.pm/formex_ecto/Formex.Ecto.CustomField.SelectAssoc.html)