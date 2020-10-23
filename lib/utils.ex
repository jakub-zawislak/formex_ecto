defmodule Formex.Ecto.Utils do
  @moduledoc false

  @doc false
  @spec is_assoc(form :: Form.t(), name :: Atom.t()) :: boolean
  def is_assoc(form, name) do
    form.struct_module.__schema__(:association, name) != nil
  end
end
