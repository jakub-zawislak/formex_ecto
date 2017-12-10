defmodule Formex.Ecto.SelectAssocWithoutChoicesType do
  use Formex.Type
  use Formex.Ecto.Type
  require Formex.Ecto.CustomField.SelectAssoc
  alias Formex.Ecto.CustomField.SelectAssoc

  def build_form(form) do
    form
    |> add(:title, :text_input, validation: [:required])
    |> add(:category_id, SelectAssoc, without_choices: true)
    |> add(:tags, SelectAssoc)
  end
end

defmodule Formex.Ecto.SelectAssoc.WithoutChoicesTest do
  use Formex.Ecto.SelectAssocCase
  use Formex.Controller
  use Formex.Ecto.Controller
  alias Formex.Ecto.SelectAssocWithoutChoicesType

  test "no choices" do
    insert_categories()
    insert_tags()

    form = create_form(SelectAssocWithoutChoicesType, %Article{})

    assert Enum.count(Formex.Form.find(form, :category_id).data[:choices]) == 0
  end

  test "label provider" do
    insert_categories()
    insert_tags()
    category = get_category(0)

    params = %{"category_id" => to_string(category.id)}
    form = create_form(SelectAssocWithoutChoicesType, %Article{}, params)

    {:error, form} = insert_form_data(form)

    assert Formex.Form.find(form, :category_id).data[:choices] == [
      {category.name, to_string(category.id)}
    ]
  end

end
