defmodule Formex.Ecto.TestModel.Avatar do
  use Formex.Ecto.TestModel

  schema "abstract table: avatars" do
    field :url, :string
    field :assoc_id, :integer

    formex_collection_child()
  end

end
