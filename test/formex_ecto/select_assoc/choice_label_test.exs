defmodule Formex.Ecto.SelectAssocChoiceLabelAtomTestType do
  use Formex.Type
  use Formex.Ecto.Type
  require Formex.Ecto.CustomField.SelectAssoc

  def build_form(form) do
    form
    |> add(:category_id, Formex.Ecto.CustomField.SelectAssoc, choice_label: :id,
    validation: [:required])
  end
end

defmodule Formex.Ecto.SelectAssocChoiceLabelFunctionTestType do
  use Formex.Type
  use Formex.Ecto.Type
  require Formex.Ecto.CustomField.SelectAssoc

  def build_form(form) do
    form
    |> add(:category_id, Formex.Ecto.CustomField.SelectAssoc, choice_label: fn category ->
      category.name <> category.name
    end, validation: [:required])
  end
end

defmodule Formex.Ecto.SelectAssoc.ChoiceLabelTest do
  use Formex.Ecto.SelectAssocCase
  alias Formex.Ecto.SelectAssocChoiceLabelAtomTestType
  alias Formex.Ecto.SelectAssocChoiceLabelFunctionTestType

  test "choice label atom" do
    insert_categories()

    form = create_form(SelectAssocChoiceLabelAtomTestType, %Article{})

    choices = Enum.at(form.items, 0).data[:choices]
    choice  = Enum.at(choices, 0)
    {choice_label, _} = choice
    assert is_number(choice_label)
  end

  test "choice label function" do
    insert_categories()

    form = create_form(SelectAssocChoiceLabelFunctionTestType, %Article{})

    choices = Enum.at(form.items, 0).data[:choices]
    choice  = Enum.at(choices, 0)
    {choice_label, _} = choice
    assert choice_label == "asdasd"
  end

end
