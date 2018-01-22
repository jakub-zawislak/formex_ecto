defmodule Formex.Ecto.Type do
  @moduledoc """
  Module that must be used in form types that uses Ecto.

  # Installation

  Just add `use Formex.Ecto.Type`

  # Example

  ```
  defmodule App.ArticleType do
    use Formex.Type
    use Formex.Ecto.Type

    def build_form(form) do
      form
      |> add(:title, :text_input, label: "Title")
      # ...
    end

    # optional
    def fields_casted_manually(_form) do
      # do some fields will be casted later?
      []
    end

    # optional
    def changeset_after_create_callback(changeset, form) do
      # do something with changeset. If you change some data here, it will be saved to database
      # since Formex 0.5, you cannot add errors to a changeset
      changeset
    end
  ```

  If you want to add errors to a changeset, see
  `c:Formex.Ecto.ChangesetValidator.changeset_validation/2`

  # Example with `Arc.Ecto`

  ```
  defmodule App.ArticleType do
    # ...

    def build_form(form) do
      form
      |> add(:image, :file_input, label: "Image")
      # ...
    end

    # Arc.Ecto.cast_attachments doesn't work if we used Ecto.Changeset.cast/3 on :image
    # (Formex.Ecto.Changest does this automatically), therefore we must indicate that this field
    # will be casted manually
    def fields_casted_manually(_form) do
      [:image]
    end

    # manually use `Arc.Ecto.cast_attachment/3`
    def changeset_after_create_callback(changeset, _form) do
      changeset
      |> cast_attachments(changeset.params, [:image])
    end
  end
  ```

  """

  defmacro __using__([]) do
    quote do
      @behaviour Formex.Ecto.Type

      def changeset_after_create_callback(changeset, _form) do
        changeset
      end

      def fields_casted_manually(_form) do
        []
      end

      defoverridable [changeset_after_create_callback: 2, fields_casted_manually: 1]
    end
  end

  @doc """
  Callback that will be called after changeset creation.

  In this callback you can modify changeset.

  Since Formex 0.5, you cannot add errors to changeset. If you want to do so, see
  `c:Formex.Ecto.ChangesetValidator.changeset_validation/2`
  """
  @callback changeset_after_create_callback(changeset :: Ecto.Changeset.t, form :: Formex.Form.t)
    :: Ecto.Changeset.t

  @doc """
  Do you have some fields that should be casted manually?

  All fields listed here will not be
  casted automatically by `Ecto.Changeset.cast/3` function. You must cast them in the
  `c:changeset_after_create_callback/2`.
  """
  @callback fields_casted_manually(form :: Formex.Form.t) :: List.t

end
