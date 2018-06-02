defmodule Formex.Ecto.SelectAssocChoiceQueryTestType do
  use Formex.Type
  use Formex.Ecto.Type
  require Formex.Ecto.CustomField.SelectAssoc
  import Ecto.Query

  def build_form(form) do
    form
    |> add(
      :category_id,
      Formex.Ecto.CustomField.SelectAssoc,
      query: fn query ->
        from(e in query, where: e.name != "Elixir")
      end,
      validation: [:required]
    )
  end
end

defmodule Formex.Ecto.SelectAssoc.QueryTest do
  use Formex.Ecto.SelectAssocCase
  alias Formex.Ecto.SelectAssocChoiceQueryTestType

  test "choice query" do
    insert_categories()

    form = create_form(SelectAssocChoiceQueryTestType, %Article{})

    choices = Enum.at(form.items, 0).data[:choices]

    assert Enum.count(choices) == 2

    {choice0, _} = Enum.at(choices, 0)
    {choice1, _} = Enum.at(choices, 1)

    assert choice0 == "Phoenix"
    assert choice1 == "Programming"
  end
end
