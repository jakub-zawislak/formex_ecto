# Guides

## Uploading files with [Arc.Ecto](https://github.com/stavro/arc_ecto)

### Type file

```elixir
defmodule App.ArticleType do
  # ...
  use Arc.Ecto.Schema
  import Ecto.Changeset, only: [cast: 3]

  def build_form(form) do
    form
    #...
    |> add(:image, :file_input)
  end

  def fields_casted_manually(_form) do
    [:image]
  end

  def changeset_after_create_callback(changeset, _form) do
    changeset
    |> cast_attachments(changeset.params, [:image])
  end

end
```

### View

Add a `multipart: true` option

```elixir
<%= formex_form_for @form, @action, [multipart: true], fn f -> %>
  ...
<%= end %>
```
