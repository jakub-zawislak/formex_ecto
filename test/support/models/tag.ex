defmodule Formex.Ecto.TestModel.Tag do
  use Formex.Ecto.TestModel

  schema "tags" do
    field(:name, :string)

    timestamps()
  end
end
