defmodule Formex.Ecto.CustomField.SelectAssoc do
  @behaviour Formex.CustomField
  import Ecto.Query
  alias Formex.Field
  alias Formex.Form

  @repo Application.get_env(:formex, :repo)

  @moduledoc """
  This module generates a `:select` field with options downloaded from Repo.

  Example of use for Article with one Category:
  ```
  schema "articles" do
    belongs_to :category, App.Category
  end
  ```
  ```
  form
  |> add(:category_id, Formex.Ecto.CustomField.SelectAssoc, label: "Category")
  ```
  Formex will find out that `:category_id` refers to App.Category schema and download all rows
  from Repo ordered by name.

  If you are using `:without_choices` option (from `Formex.Field.create_field/3`), you don't
  need to implement `:choice_label_provider`, this module will do it for you.

  ## Options

    * `choice_label` - controls the content of `<option>`. May be the name of a field or a function.
      Example of use:

      ```
      form
      |> add(:article_id, SelectAssoc, label: "Article", choice_label: :title)
      ```
      ```
      form
      |> add(:user_id, SelectAssoc, label: "User", choice_label: fn user ->
        user.first_name<>" "<>user.last_name
      end)
      ```

    * `query` - an additional query that filters the choices list. Example of use:

      ```
      form
      |> add(:user_id, SelectAssoc, query: fn query ->
        from e in query,
          where: e.fired == false
      end)
      ```

    * `group_by` - wraps `<option>`'s in `<optgroup>`'s. May be `:field_name`,
      `:assoc_name` or `[:assoc_name, :field_name]`

      Example of use:

      ```
      schema "users" do
        field :first_name, :string
        field :last_name, :string
        belongs_to :department, App.Department
      end
      ```

      ```
      schema "departments" do
        field :name, :string
        field :description, :string
      end
      ```

      Group by last name of user:
      ```
      form
      |> add(:user_id, SelectAssoc, group_by: :last_name)
      ```

      Group by department, by `:name` (default) field:
      ```
      form
      |> add(:user_id, SelectAssoc, group_by: :department)
      ```

      Group by department, but by another field
      ```
      form
      |> add(:user_id, SelectAssoc, group_by: [:department, :description])
      ```

    * `search_field` - schema field to be used in query in `search/3`.
      If it's a `nil`, then the final value depends on the `choice_label` value:
      * if `:choice_label` is nil, `:search_field` becomes `:name`
      * if `:choice_label` is an atom, `:search_field` gets this atom
      * if `:choice_label` is a function, `:search_field` is still nil

    * `search_query` - if the `search_field` functionality is not enough for you, use this
      to apply your own query. It's necessary if you have more than one field to search,
      e.g. first name and last name.

  """

  @doc false
  def create_field(form, name, opts) do
    if form.struct_module.__schema__(:association, name) == nil do
      create_field_single(form, name, opts)
    else
      create_field_multiple(form, name, opts)
    end
  end

  @doc """
  Can be used in controller, along with `:without_choices` option from
  `Formex.Field.create_field/3`.

  It gets rows from repo that matches given `search` argument and returns them as
  `{label, id}` list.

  Example of use for
  [Ajax-Bootstrap-Select](https://github.com/truckingsim/Ajax-Bootstrap-Select):

  ```
  def search_categories(conn, %{"q" => search}) do
    result = create_form(App.ArticleType, %Article{})
    |> Formex.Ecto.CustomField.SelectAssoc.search(:category_id, search)
    |> Enum.map(fn {label, id} -> %{
      "value" => id,
      "text"  => label
     } end)

    json(conn, result)
  end
  ```
  """
  @spec search(form :: Form.t(), name :: atom, search :: String.t()) :: List.t()
  def search(form, name, search) do
    name_id =
      name
      |> Atom.to_string
      |> (&Regex.replace(~r/_id$/, &1, "")).()
      |> String.to_atom()

    search = "%" <> search <> "%"

    module = form.struct_module.__schema__(:association, name_id).related

    form_field = Form.find(form, name)
    opts = form_field.opts

    query =
      if opts[:search_query] do
        opts[:search_query].(module, search)
      else
        search_field =
          case opts[:search_field] do
            x when is_atom(x) and not is_nil(x) ->
              x

            _ ->
              case opts[:choice_label] do
                x when is_atom(x) and not is_nil(x) ->
                  x

                x when is_nil(x) ->
                  :name

                x when is_function(x) ->
                  raise "Provide a value for :search_field option in #{name} field"
              end
          end

        from(e in module, where: like(field(e, ^search_field), ^search))
      end

    query
    |> apply_query(opts[:query])
    |> @repo.all
    |> group_rows(opts[:group_by])
    |> generate_choices(opts[:choice_label])
  end

  defp create_field_single(form, name_id, opts) do
    name =
      name_id
      |> Atom.to_string
      |> (&Regex.replace(~r/_id$/, &1, "")).()
      |> String.to_atom()

    module = form.struct_module.__schema__(:association, name).related

    opts =
      opts
      |> parse_opts(module)
      |> put_choices(module)

    Field.create_field(:select, name_id, opts)
  end

  defp create_field_multiple(form, name, opts) do
    module = form.struct_module.__schema__(:association, name).related

    opts =
      opts
      |> parse_opts(module)
      |> put_choices(module)

    selected =
      if form.struct.id do
        form.struct
        |> @repo.preload(name)
        |> Map.get(name)
        |> Enum.map(& &1.id)
      else
        []
      end

    phoenix_opts = Keyword.merge(opts[:phoenix_opts] || [], selected: selected)

    opts = Keyword.merge(opts, phoenix_opts: phoenix_opts)

    Field.create_field(:multiple_select, name, opts)
  end

  defp put_choices(opts, module) do
    if opts[:without_choices] do
      Keyword.put(opts, :choice_label_provider, fn id ->
        query = from(e in module, where: e.id == ^id)

        row =
          query
          |> apply_query(opts[:query])
          |> apply_group_by_assoc(opts[:group_by])
          |> @repo.one

        if row do
          get_choice_label_val(row, opts[:choice_label])
        else
          nil
        end
      end)
    else
      choices =
        module
        |> apply_query(opts[:query])
        |> apply_group_by_assoc(opts[:group_by])
        |> @repo.all
        |> group_rows(opts[:group_by])
        |> generate_choices(opts[:choice_label])

      Keyword.put(opts, :choices, choices)
    end
  end

  defp parse_opts(opts, module) do
    opts
    |> Keyword.update(:group_by, nil, fn property_path ->
      cond do
        is_list(property_path) ->
          property_path

        is_atom(property_path) ->
          if module.__schema__(:association, property_path) do
            [property_path, :name]
          else
            [property_path]
          end

        true ->
          nil
      end
    end)
  end

  defp apply_query(query, custom_query) when is_function(custom_query) do
    custom_query.(query)
  end

  defp apply_query(query, _) do
    query
  end

  defp apply_group_by_assoc(query, [assoc | t]) do
    if Enum.count(t) > 0 do
      from(query, preload: [^assoc])
    else
      query
    end
  end

  defp apply_group_by_assoc(query, _) do
    query
  end

  defp group_rows(rows, property_path) when is_list(property_path) do
    rows
    |> Enum.group_by(&Formex.Utils.Map.get_property(&1, property_path))
  end

  defp group_rows(rows, _) do
    rows
  end

  defp generate_choices(rows, choice_label) when is_list(rows) do
    rows
    |> Enum.map(fn row ->
      label = get_choice_label_val(row, choice_label)

      {label, row.id}
    end)
    |> Enum.sort(fn {name1, _}, {name2, _} ->
      name1 < name2
    end)
  end

  defp generate_choices(grouped_rows, choice_label) when is_map(grouped_rows) do
    grouped_rows
    |> Enum.map(fn {group_label, rows} ->
      {group_label, generate_choices(rows, choice_label)}
    end)
    |> Map.new(& &1)
  end

  defp get_choice_label_val(row, choice_label) do
    cond do
      is_function(choice_label) ->
        choice_label.(row)

      !is_nil(choice_label) ->
        Map.get(row, choice_label)

      true ->
        if Map.has_key?(row, :name) do
          row.name
        else
          throw("""
          Field :name not found in the schema.
          You should provide the :choice_label value in SelectAssoc
          """)
        end
    end
  end
end
