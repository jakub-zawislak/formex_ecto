defmodule Formex.Ecto.SelectAssocBasicTestType do
  use Formex.Type
  use Formex.Ecto.Type
  require Formex.Ecto.CustomField.SelectAssoc

  def build_form(form) do
    form
    |> add(:category_id, Formex.Ecto.CustomField.SelectAssoc, phoenix_opts: [
      prompt: "Choose category"
    ], validation: [:required])
    |> add(:tags, Formex.Ecto.CustomField.SelectAssoc, phoenix_opts: [
      prompt: "Choose tag"
    ], validation: [:required])
  end
end

defmodule Formex.Ecto.SelectAssoc.BasicTest do
  use Formex.Ecto.SelectAssocCase
  alias Formex.Ecto.SelectAssocBasicTestType

  test "basic" do
    insert_categories()
    insert_tags()

    form = create_form(SelectAssocBasicTestType, %Article{})

    {:safe, form_html} = Formex.View.formex_form_for(form, "", fn f ->
      Formex.View.formex_rows(f)
    end)

    form_str = form_html |> to_string

    assert String.match?(form_str, ~r/Programming/)
    assert String.match?(form_str, ~r/tag1/)
    assert String.match?(form_str, ~r/multiple/)
  end

end
