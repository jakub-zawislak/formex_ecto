defmodule Formex.Ecto.MultipleSelectCase do
  defmacro __using__(_) do
    quote do
      use Formex.Ecto.TestCase
      import Formex.Builder
      alias Formex.Ecto.TestModel.User
    end
  end
end
