defmodule Formex.Ecto.TestModel.Category do
  use Formex.Ecto.TestModel

  schema "categories" do
    field(:name, :string)

    timestamps()
  end

  def ordered(query) do
    from(c in query, order_by: c.id)
  end
end
