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
    def modify_changeset(changeset, form) do
      # Modify changeset. If you change some data here, it will be saved to database
      # You can also add validation rules here
      changeset
    end
  ```

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
    def modify_changeset(changeset, _form) do
      changeset
      |> cast_attachments(changeset.params, [:image])
    end
  end
  ```
  """

  defmacro __using__([]) do
    quote do
      @behaviour Formex.Ecto.Type

      def modify_changeset(changeset, _form) do
        changeset
      end

      def fields_casted_manually(_form) do
        []
      end

      defoverridable modify_changeset: 2, fields_casted_manually: 1
    end
  end

  @doc """
  Callback that will be called after changeset creation.

  In this callback you can modify changeset.

  Any errors added here will not be displayed together with errors added normally, i.e. using
  `Formex.Validator`. Insert/update actions are performed only when Formex.Validator validation
  passes. Errors from changeset are added to form after insert/update failure.
  """
  @callback modify_changeset(changeset :: Ecto.Changeset.t(), form :: Formex.Form.t()) ::
              Ecto.Changeset.t()

  @doc """
  Do you have some fields that should be casted manually?

  All fields listed here will not be
  casted automatically by `Ecto.Changeset.cast/3` function. You must cast them in the
  `c:modify_changeset/2`.
  """
  @callback fields_casted_manually(form :: Formex.Form.t()) :: List.t()
end
