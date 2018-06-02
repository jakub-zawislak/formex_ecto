defmodule Formex.Ecto.TestModel.Article do
  use Formex.Ecto.TestModel

  schema "articles" do
    field(:title, :string)
    field(:content, :string)
    field(:visible, :boolean)

    belongs_to(:category, Formex.Ecto.TestModel.Category)
    belongs_to(:user, Formex.Ecto.TestModel.User)

    many_to_many(
      :tags,
      Formex.Ecto.TestModel.Tag,
      join_through: "articles_tags",
      on_delete: :delete_all,
      on_replace: :delete
    )

    timestamps()
  end
end
