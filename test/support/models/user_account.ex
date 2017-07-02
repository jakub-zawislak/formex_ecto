defmodule Formex.Ecto.TestModel.UserAccount do
  use Formex.Ecto.TestModel

  schema "user_accounts" do
    field :number, :string
    field :removed, :boolean

    belongs_to :user, Formex.Ecto.TestModel.User

    timestamps()
    formex_collection_child()
  end

  def ordered(query) do
    from c in query,
      order_by: c.id
  end

end
