defmodule Formex.Ecto.Embedded.Collection.UserAddressType do
  use Formex.Type
  use Formex.Ecto.Type

  def build_form(form) do
    form
    |> add(:street, :text_input, label: "Street", validation: [:required])
    |> add(:city, :text_input, label: "City", validation: [:required])
    |> add(:postal_code, :text_input, label: "Postal code", validation: [:required])
  end
end

defmodule Formex.Ecto.Embedded.Collection.UserType do
  use Formex.Type

  def build_form(form) do
    form
    |> add(:first_name, :text_input, label: "Imię", validation: [:required])
    |> add(:last_name, :text_input, label: "Nazwisko", validation: [:required])
    |> add(:user_addresses, Formex.Ecto.Embedded.Collection.UserAddressType)
  end
end

defmodule Formex.Ecto.Embedded.CollectionTest do
  use Formex.Ecto.EmbeddedCase
  use Formex.Controller
  use Formex.Ecto.Controller
  alias Formex.Ecto.Embedded.Collection.UserType

  test "view" do
    form = create_form(UserType, %User{first_name: "Bożątko"})

    {:safe, form_html} = Formex.View.formex_form_for(form, "", fn f ->
      Formex.View.formex_rows(f)
    end)

    form_str = form_html |> to_string

    assert String.match?(form_str, ~r/Bożątko/)
    assert String.match?(form_str, ~r/Imię/)
    assert String.match?(form_str, ~r/Street/)
  end

  test "insert user and user_address" do
    params      = %{"first_name" => "a", "last_name" => "a"}
    form        = create_form(UserType, %User{}, params)
    {:ok,    _} = handle_form(form)

    params      = %{"first_name" => "a", "last_name" => "a", "user_addresses" => %{
      "0" => %{"street" => ""}
    }}
    form        = create_form(UserType, %User{}, params)
    {:error, _} = handle_form(form)

    params      = %{"first_name" => "a", "last_name" => "a", "user_addresses" => %{
      "0" => %{"street" => "s", "postal_code" => "p", "city" => "c"}
    }}
    form        = create_form(UserType, %User{}, params)
    {:ok, user} = handle_form(form)

    assert user.first_name == "a"
    assert Enum.at(user.user_addresses, 0).city == "c"
  end
end
