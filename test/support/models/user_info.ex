defmodule Formex.Ecto.TestModel.UserInfo do
  use Formex.Ecto.TestModel

  schema "user_infos" do
    field :section, :string

    has_one :user, Formex.Ecto.TestModel.User

    timestamps()
  end

end
