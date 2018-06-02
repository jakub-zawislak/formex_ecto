defmodule Formex.Ecto.Validator do
  alias Formex.FormCollection
  alias Formex.FormNested
  alias Formex.Form

  @moduledoc false

  def assign_changeset_errors(form, changeset) do
    form_items = Enum.map(form.items, fn item ->

      if Form.is_controllable(item) and Map.has_key?(changeset.changes, item.struct_name) do
        case item do
          collection = %FormCollection{} ->
            forms = collection.forms
            |> Enum.with_index()
            |> Enum.map(fn {nested, index} ->

              nested_changeset = changeset.changes
              |> Map.get(item.struct_name)
              |> Enum.at(index)

              form = assign_changeset_errors(nested.form, nested_changeset)

              %{nested | form: form}
            end)

            %{collection | forms: forms}

          nested = %FormNested{} ->
            nested_changeset = changeset.changes
            |> Map.get(item.struct_name)

            %{nested | form: assign_changeset_errors(nested.form, nested_changeset)}

          _ -> item
        end
      else
        item
      end

    end)

    errors = changeset.errors
    |> Enum.reduce([], fn ({key, val}, acc) ->
      IO.inspect key
      name = Form.get_name_by_struct_name(form, key)

      Keyword.update(acc, name, [val], &([val|&1]))
    end)

    form
    |> Map.put(:items, form_items)
    |> Map.put(:errors, errors)
    |> Formex.Validator.translate_errors
  end

end
