defmodule Formex.Ecto.ChangesetValidator do
  @behaviour Formex.Validator
  alias Formex.Form
  alias Formex.Field
  alias Ecto.Changeset

  @moduledoc """
  Changeset validator adapter for Formex.

  It was created to make use of validation functions included in `Ecto.Changeset`. This module
  creates a fake changeset to perform validation rules.

  You don't need to use this validator - any
  [validator](https://hexdocs.pm/formex/Formex.Validator.html) works with Ecto schemas.
  You can also add errors in the `c:Formex.Ecto.modify_changeset/2` callback, which modifies real
  changeset.

  # Limitations

  * can be used only with Ecto schemas.
  * `length` validation for collections doesn't work.
    Maybe there is a way to fix it. If you need this now - use Vex validator instead.

  # Installation

  See `Formex.Validator` docs.

  # Usage

  ```
  defmodule App.UserType do
    use Formex.Type
    use Formex.Ecto.Type
    use Formex.Ecto.ChangesetValidator # <- add this
  ```

  ```
  def build_form(form) do
    form
    |> add(:username, :text_input, validation: [
      :required
    ])
    |> add(:email, :text_input, validation: [
      required: [message: "give me your email!"],
      format: [arg: ~r/@/]
    ])
    |> add(:age, :text_input, validation: [
      :required,
      inclusion: [arg: 13..100, message: "you must be 13."]
    ])
  end
  ```

  Keys from `validation` list are converted to `validate_` functions from
  `Ecto.Changeset`. For example `required` -> `Ecto.Changeset.validate_required/3`.

  Value is list of options. If function requires additional argument
  (e.g. `Ecto.Changeset.validate_format/4` needs format as third argument)
  it must be passed as `:arg` option.

  """

  defmacro __using__([]) do
    quote do
      import Ecto.Changeset
    end
  end

  @spec validate(Form.t) :: Form.t
  def validate(form) do
    # the `create_changeset_for_validation` creates changeset without collections
    # `length` doesn't validate empty collections so we don't need them

    changeset = Formex.Ecto.Changeset.create_changeset_for_validation(form)

    errors_fields = form
    |> Form.get_fields_validatable
    |> Enum.flat_map(fn item ->
      validate_field(changeset, item)
    end)

    errors = errors_fields
    |> Enum.reduce([], fn ({key, val}, acc) ->
      Keyword.update(acc, key, [val], &([val|&1]))
    end)

    form
    |> Map.put(:errors, errors)
  end

  @spec validate_field(changeset :: Changeset.t, field :: Field.t) :: List.t
  defp validate_field(changeset, field) do
    field.validation
    |> Enum.reduce(changeset, fn (validation, changeset) ->
      {name, opts} = case validation do
        {name, opts} when is_list(opts)
          -> {name, opts}
        name
          -> {name, []}
      end

      {arg, opts} = Keyword.pop(opts, :arg)

      args = if arg do
        [changeset, field.name, arg, opts]
      else
        [changeset, field.name, opts]
      end

      name = "validate_"<>to_string(name) |> String.to_atom

      apply(Changeset, name, args)
    end)
    |> Map.get(:errors)
  end

end
