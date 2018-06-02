defmodule Formex.Ecto.TestModel.User do
  use Formex.Ecto.TestModel

  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:age, :integer)
    field(:degrees, {:array, :string})

    belongs_to(:department, Formex.Ecto.TestModel.Department)
    belongs_to(:user_info, Formex.Ecto.TestModel.UserInfo)
    has_many(:user_addresses, Formex.Ecto.TestModel.UserAddress)
    has_many(:user_accounts, Formex.Ecto.TestModel.UserAccount)

    embeds_many :schools, School do
      field(:name, :string)
      formex_collection_child()
    end

    timestamps()
  end

  def ordered(query) do
    from(c in query, order_by: c.id)
  end
end
