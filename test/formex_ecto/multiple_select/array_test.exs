defmodule Formex.Ecto.MultipleSelect.ArrayTestType do
  use Formex.Type
  use Formex.Ecto.Type

  def build_form(form) do
    form
    |> add(:degrees, :multiple_select, choices: [
      "Bachelor",
      "Master",
      "Doctor",
    ])
  end
end

defmodule Formex.Ecto.MultipleSelect.ArrayTest do
  use Formex.Ecto.MultipleSelectCase
  use Formex.Ecto.Controller
  alias Formex.Ecto.MultipleSelect.ArrayTestType

  test "view" do
    form = create_form(ArrayTestType, %User{})

    Formex.View.formex_form_for(form, "", fn f ->
      Formex.View.formex_rows(f)
    end)
  end

  test "insert" do
    params = %{"degrees" => ["Master", "Doctor"]}

    form = create_form(ArrayTestType, %User{}, params)

    {:ok, user} = insert_form_data(form)

    assert user.degrees == ["Master", "Doctor"]
  end

end
