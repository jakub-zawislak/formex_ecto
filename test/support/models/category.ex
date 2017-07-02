defmodule Formex.Ecto.TestModel.Category do
  use Formex.Ecto.TestModel

  schema "categories" do
    field :name, :string

    timestamps()
  end
end
