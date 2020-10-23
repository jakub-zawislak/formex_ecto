defmodule Formex.Ecto.Collection.EmbedsMany.UserSchoolType do
  use Formex.Type
  use Formex.Ecto.Type

  def build_form(form) do
    form
    |> add(:name, :text_input, label: "School name", validation: [:required])
  end
end

defmodule Formex.Ecto.Collection.EmbedsMany.UserType do
  use Formex.Type
  use Formex.Ecto.Type

  def build_form(form) do
    form
    |> add(:first_name, :text_input, label: "Name", validation: [:required])
    |> add(:last_name, :text_input, label: "Surname", validation: [:required])
    |> add(:schools, Formex.Ecto.Collection.EmbedsMany.UserSchoolType)
  end
end

defmodule Formex.Ecto.Collection.EmbedsManyTest do
  use Formex.Ecto.CollectionCase
  use Formex.Controller
  use Formex.Ecto.Controller
  alias Formex.Ecto.Collection.EmbedsMany.UserType

  test "view" do
    insert_users()

    form = create_form(UserType, %User{})

    {:safe, form_html} =
      Formex.View.formex_form_for(form, "", fn f ->
        Formex.View.formex_rows(f)
      end)

    form_str = form_html |> to_string

    assert String.match?(form_str, ~r/Surname/)
    assert String.match?(form_str, ~r/School name/)
  end

  test "insert user and school" do
    params = %{"first_name" => "a", "last_name" => "a"}
    form = create_form(UserType, %User{}, params)
    {:ok, _} = insert_form_data(form)

    params = %{
      "first_name" => "a",
      "last_name" => "a",
      "schools" => %{
        "0" => %{"name" => "", "formex_id" => "some-id"}
      }
    }

    form = create_form(UserType, %User{}, params)
    {:error, _} = insert_form_data(form)

    params = %{
      "first_name" => "a",
      "last_name" => "a",
      "schools" => %{
        "0" => %{"name" => "s", "formex_id" => "some-id"}
      }
    }

    form = create_form(UserType, %User{}, params)
    {:ok, user} = insert_form_data(form)

    assert Enum.at(user.schools, 0).name == "s"
  end

  test "edit user and school" do
    insert_users()

    user = get_user(0)

    params = %{
      "first_name" => "a",
      "last_name" => "a",
      "schools" => %{
        "0" => %{"name" => ""}
      }
    }

    form = create_form(UserType, user, params)
    {:error, _} = update_form_data(form)

    params = %{
      "first_name" => "a",
      "last_name" => "a",
      "schools" => %{
        "0" => %{"name" => "name0"}
      }
    }

    form = create_form(UserType, user, params)
    {:ok, user} = update_form_data(form)

    params = %{
      "first_name" => "a",
      "last_name" => "a",
      "schools" => %{
        "0" => %{"id" => Enum.at(user.schools, 0).id, "name" => "name0new"},
        "1" => %{"formex_id" => "1", "name" => "name1"},
        "2" => %{"formex_id" => "2", "name" => "name2"}
      }
    }

    # download it again, we want unloaded school
    user = get_user(0)
    form = create_form(UserType, user, params)
    {:ok, user} = update_form_data(form)

    assert Enum.at(user.schools, 0).name == "name0new"
    assert Enum.at(user.schools, 1).name == "name1"
    assert Enum.at(user.schools, 2).name == "name2"
  end

  test "remove school" do
    insert_users()

    user = get_user(1)

    school1 = Enum.at(user.schools, 0)
    school2 = Enum.at(user.schools, 1)

    params = %{
      "first_name" => "a",
      "last_name" => "a",
      "schools" => %{
        "0" => %{"id" => school1.id, "name" => "a", "formex_delete" => "true"},
        "1" => %{"id" => school2.id, "name" => "a"}
      }
    }

    form = create_form(UserType, user, params)
    {:ok, _} = update_form_data(form)

    user = get_user(1)

    assert Enum.at(user.schools, 0).id == school2.id
  end
end
