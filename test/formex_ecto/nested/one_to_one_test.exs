defmodule Formex.Ecto.Nested.OneToOne.UserInfoType do
  use Formex.Type
  use Formex.Ecto.Type

  def build_form(form) do
    form
    |> add(:section, :text_input, label: "Sekcja", validation: [:required])
  end
end

defmodule Formex.Ecto.Nested.OneToOne.UserType do
  use Formex.Type
  use Formex.Ecto.Type

  def build_form(form) do
    form
    |> add(:first_name, :text_input, label: "Imię", validation: [:required])
    |> add(:last_name, :text_input, label: "Nazwisko", validation: [:required])
    |> add(:user_info, Formex.Ecto.Nested.OneToOne.UserInfoType)
  end
end

defmodule Formex.Ecto.Nested.OneToOneTest do
  use Formex.Ecto.NestedCase
  use Formex.Controller
  use Formex.Ecto.Controller
  alias Formex.Ecto.Nested.OneToOne.UserType

  test "view" do
    insert_users()

    form = create_form(UserType, %User{})

    {:safe, form_html} = Formex.View.formex_form_for(form, "", fn f ->
      Formex.View.formex_rows(f)
    end)

    form_str = form_html |> to_string

    assert String.match?(form_str, ~r/Imię/)
    assert String.match?(form_str, ~r/Sekcja/)
  end

  test "insert user and user_info" do
    params      = %{"first_name" => "a", "last_name" => "a", "user_info" => %{"section" => ""}}
    form        = create_form(UserType, %User{}, params)
    {:error, _} = insert_form_data(form)

    params      = %{"first_name" => "a", "last_name" => "a", "user_info" => %{"section" => "s"}}
    form        = create_form(UserType, %User{}, params)
    {:ok, user} = insert_form_data(form)

    assert user.user_info.section == "s"
  end

  test "edit user and user_info" do
    insert_users()

    user = get_first_user()

    params      = %{"user_info" => %{"section" => ""}}
    form        = create_form(UserType, user, params)
    {:error, _} = update_form_data(form)

    params      = %{"user_info" => %{"section" => "s"}}
    form        = create_form(UserType, user, params)
    {:ok, user} = update_form_data(form)

    params      = %{"user_info" => %{"id" => user.user_info.id, "section" => "a"}}
    user        = get_first_user() # download it again, we want unloaded user_info

    form        = create_form(UserType, user, params)
    {:ok, user} = update_form_data(form)

    assert user.user_info.section == "a"
  end
end
