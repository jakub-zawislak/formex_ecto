defmodule Formex.Ecto.Polymorphic.CollectionPolymorphic.CommentType do
  use Formex.Type
  use Formex.Ecto.Type

  def build_form(form) do
    form
    |> add(:content, :text_input)
  end
end

defmodule Formex.Ecto.Polymorphic.CollectionPolymorphic.ArticleType do
  use Formex.Type
  use Formex.Ecto.Type

  def build_form(form) do
    form
    |> add(:comments, Formex.Ecto.Polymorphic.CollectionPolymorphic.CommentType)
  end
end

defmodule Formex.Ecto.Polymorphic.CollectionPolymorphic.AvatarType do
  use Formex.Type
  use Formex.Ecto.Type

  def build_form(form) do
    form
    |> add(:url, :text_input)
  end
end

defmodule Formex.Ecto.Polymorphic.CollectionPolymorphic.UserType do
  use Formex.Type
  use Formex.Ecto.Type

  def build_form(form) do
    form
    |> add(:avatar, Formex.Ecto.Polymorphic.CollectionPolymorphic.AvatarType)
  end
end

defmodule Formex.Ecto.Polymorphic.CollectionPolymorphicTest do
  use Formex.Ecto.CollectionPolymorphicCase
  use Formex.Controller
  use Formex.Ecto.Controller
  alias Formex.Ecto.Polymorphic.CollectionPolymorphic.ArticleType
  alias Formex.Ecto.Polymorphic.CollectionPolymorphic.UserType

  test "edit and insert article's comment" do
    insert_articles()
    article = get_article()

    params = %{
      "content" => "Some content",
      "comments" => %{
        "0" => %{"id" => Enum.at(article.comments, 0).id |> to_string, "content" => "I like cars"},
        "1" => %{"formex_id" => "1", "content" => "I like PHP"},
      }
    }

    form = create_form(ArticleType, article, params)
    {:ok, article} = update_form_data(form)

    assert Enum.at(article.comments, 0).content == "I like cars"
    assert Enum.at(article.comments, 1).content == "I like PHP"
  end

  test "insert user's avatar" do
    insert_users()
    user = get_user()

    params = %{
      "avatar" => %{"url" => "x"}
    }

    form = create_form(UserType, user, params)
    {:ok, user} = update_form_data(form)

    assert user.avatar.url == "x"
  end
end
