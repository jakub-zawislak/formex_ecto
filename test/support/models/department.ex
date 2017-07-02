defmodule Formex.Ecto.TestModel.Department do
  use Formex.Ecto.TestModel

  schema "departments" do
    field :name, :string

    timestamps()
  end

end
