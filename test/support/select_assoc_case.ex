defmodule Formex.Ecto.SelectAssocCase do
  defmacro __using__(_) do
    quote do
      use Formex.Ecto.TestCase
      import Formex.Builder
      alias Formex.Ecto.TestModel.Article
      alias Formex.Ecto.TestModel.Category
      alias Formex.Ecto.TestModel.Tag
      alias Formex.Ecto.TestModel.User
      alias Formex.Ecto.TestModel.Department
      alias Formex.Ecto.TestRepo

      def insert_categories() do
        TestRepo.insert(%Category{name: "Programming"})
        TestRepo.insert(%Category{name: "Elixir"})
        TestRepo.insert(%Category{name: "Phoenix"})
      end

      def insert_tags() do
        TestRepo.insert(%Tag{name: "tag1"})
        TestRepo.insert(%Tag{name: "tag2"})
        TestRepo.insert(%Tag{name: "tag3"})
      end

      def insert_users() do
        dep1 = TestRepo.insert!(%Department{name: "Administration"})
        dep2 = TestRepo.insert!(%Department{name: "Sales"})
        dep3 = TestRepo.insert!(%Department{name: "Accounting"})

        TestRepo.insert(%User{
          department_id: dep3.id,
          first_name: "Grażyna",
          last_name: "Kowalska"
        })

        TestRepo.insert(%User{department_id: dep1.id, first_name: "Wiesio", last_name: "Nowak"})

        TestRepo.insert(%User{
          department_id: dep3.id,
          first_name: "Krystyna",
          last_name: "Pawłowicz"
        })

        TestRepo.insert(%User{department_id: dep1.id, first_name: "Jan", last_name: "Cebula"})
        TestRepo.insert(%User{department_id: dep2.id, first_name: "Przemek", last_name: "Cebula"})
      end

      def get_category(key) do
        Category
        |> Category.ordered()
        |> TestRepo.all()
        |> Enum.at(key)
      end
    end
  end
end
