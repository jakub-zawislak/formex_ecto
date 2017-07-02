defmodule Formex.Ecto.TestModel do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      use Formex.Ecto.Schema

      import Ecto
      import Ecto.Query
    end
  end
end
