defmodule Formex.Ecto.TestModel.Comment do
  use Formex.Ecto.TestModel

  schema "abstract table: comments" do
    field :content, :string
    field :assoc_id, :integer

    formex_collection_child()
  end

end
