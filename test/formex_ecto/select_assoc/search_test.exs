defmodule Formex.Ecto.SelectAssoc.Search.BasicType do
  use Formex.Type
  use Formex.Ecto.Type
  require Formex.Ecto.CustomField.SelectAssoc
  alias Formex.Ecto.CustomField.SelectAssoc

  def build_form(form) do
    form
    |> add(:category_id, SelectAssoc)
    |> add(:tags, SelectAssoc)
  end
end

defmodule Formex.Ecto.SelectAssoc.Search.SearchFieldType do
  use Formex.Type
  use Formex.Ecto.Type
  require Formex.Ecto.CustomField.SelectAssoc
  alias Formex.Ecto.CustomField.SelectAssoc

  def build_form(form) do
    form
    |> add(
      :user_id,
      SelectAssoc,
      choice_label: &(&1.first_name <> &1.last_name),
      search_field: :first_name
    )
  end
end

defmodule Formex.Ecto.SelectAssoc.Search.SearchQueryType do
  use Formex.Type
  use Formex.Ecto.Type
  require Formex.Ecto.CustomField.SelectAssoc
  alias Formex.Ecto.CustomField.SelectAssoc
  import Ecto.Query

  def build_form(form) do
    form
    |> add(
      :user_id,
      SelectAssoc,
      choice_label: :first_name,
      search_query: fn query, search ->
        from(e in query, where: like(e.last_name, ^search))
      end
    )
  end
end

defmodule Formex.Ecto.SelectAssoc.SearchTest do
  use Formex.Ecto.SelectAssocCase
  use Formex.Controller
  use Formex.Ecto.Controller
  alias Formex.Ecto.SelectAssoc.Search.BasicType
  alias Formex.Ecto.SelectAssoc.Search.SearchFieldType
  alias Formex.Ecto.SelectAssoc.Search.SearchQueryType
  alias Formex.Ecto.CustomField.SelectAssoc

  test "basic single" do
    insert_categories()

    form = create_form(BasicType, %Article{})

    choices = SelectAssoc.search(form, :category_id, "ix")

    assert Enum.count(choices) == 2
    assert choices |> Enum.at(0) |> elem(0) == "Elixir"
    assert choices |> Enum.at(1) |> elem(0) == "Phoenix"
  end

  test "basic multiple" do
    insert_tags()

    form = create_form(BasicType, %Article{})

    choices = SelectAssoc.search(form, :tags, "2")

    assert Enum.count(choices) == 1
    assert choices |> Enum.at(0) |> elem(0) == "tag2"
  end

  test "search field" do
    insert_users()

    form = create_form(SearchFieldType, %Article{})

    choices = SelectAssoc.search(form, :user_id, "Ja")

    assert Enum.count(choices) == 1
    assert choices |> Enum.at(0) |> elem(0) == "JanCebula"
  end

  test "search query" do
    insert_users()

    form = create_form(SearchQueryType, %Article{})

    choices = SelectAssoc.search(form, :user_id, "Ceb")

    assert Enum.count(choices) == 2
    assert choices |> Enum.at(0) |> elem(0) == "Jan"
    assert choices |> Enum.at(1) |> elem(0) == "Przemek"
  end
end
