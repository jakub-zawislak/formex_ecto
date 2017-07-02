defmodule Formex.Ecto.Embedded.Nested.UserInfoType do
  use Formex.Type
  use Formex.Ecto.Type

  def build_form(form) do
    form
    |> add(:section, :text_input, label: "Sekcja", validation: [:required])
  end
end

defmodule Formex.Ecto.Embedded.Nested.UserType do
  use Formex.Type
  use Formex.Ecto.Type

  def build_form(form) do
    form
    |> add(:first_name, :text_input, label: "Imię", validation: [:required])
    |> add(:last_name, :text_input, label: "Nazwisko", validation: [:required])
    |> add(:user_info, Formex.Ecto.Nested.OneToOne.UserInfoType)
  end
end

defmodule Formex.Ecto.Embedded.NestedTest do
  use Formex.Ecto.EmbeddedCase
  use Formex.Controller
  use Formex.Ecto.Controller
  alias Formex.Ecto.Embedded.Nested.UserType

  test "view" do
    form = create_form(UserType, %User{})

    {:safe, form_html} = Formex.View.formex_form_for(form, "", fn f ->
      Formex.View.formex_rows(f)
    end)

    form_str = form_html |> to_string

    assert String.match?(form_str, ~r/Sekcja/)
  end

  test "insert user and user_info" do
    params      = %{"first_name" => "a", "last_name" => "a", "user_info" => %{"section" => ""}}
    form        = create_form(UserType, %User{}, params)
    {:error, _} = handle_form(form)

    params      = %{"first_name" => "a", "last_name" => "a", "user_info" => %{"section" => "s"}}
    form        = create_form(UserType, %User{}, params)
    {:ok, user} = handle_form(form)

    assert user.user_info.section == "s"
  end
end
