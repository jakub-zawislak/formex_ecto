defmodule Formex.Ecto.EmbeddedCase do
  defmacro __using__(_) do
    quote do
      use Formex.Ecto.TestCase
      import Formex.Builder
      alias Formex.Ecto.TestModelEmbedded.User
    end
  end
end
