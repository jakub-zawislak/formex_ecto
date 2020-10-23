defmodule Formex.Ecto.CollectionPolymorphicCase do
  defmacro __using__(_) do
    quote do
      use Formex.Ecto.TestCase
      import Formex.Builder
      alias Formex.Ecto.TestModel.Article
      alias Formex.Ecto.TestModel.Comment
      alias Formex.Ecto.TestModel.User
      alias Formex.Ecto.TestRepo

      def insert_articles() do
        {:ok, art} = TestRepo.insert(%Article{
          content: "Some content",
        })

        art
        |> Ecto.build_assoc(:comments)
        |> Map.put(:content, "I like trains")
        |> TestRepo.insert
      end

      def get_article() do
        Article
        |> TestRepo.all()
        |> Enum.at(0)
        |> TestRepo.preload(:comments)
      end

      def insert_users() do
        {:ok, user} = TestRepo.insert(%User{})
      end

      def get_user() do
        User
        |> TestRepo.all()
        |> Enum.at(0)
        |> TestRepo.preload(:avatar)
      end
    end
  end
end
