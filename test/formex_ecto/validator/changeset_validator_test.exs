defmodule Formex.Ecto.Validator.ChangesetValidatorTest.UserType do
  use Formex.Type
  use Formex.Ecto.Type
  use Formex.Ecto.ChangesetValidator

  def build_form(form) do
    form
    |> add(:first_name, validation: [:required])
    |> add(
      :last_name,
      validation: [
        required: [message: "give me your name!"]
      ]
    )
    |> add(
      :age,
      validation: [
        :required,
        inclusion: [arg: 13..100, message: "you must be 13."]
      ]
    )

    # |> add(:user_addresses, Formex.Ecto.Validator.ChangesetValidatorTest.UserAddressType,
    #   validation: [length: [min: 2]]
    # )
  end

  def validator, do: Formex.Ecto.ChangesetValidator
end

# defmodule Formex.Ecto.Validator.ChangesetValidatorTest.UserAddressType do
#   use Formex.Type
#   use Formex.Ecto.Type
#   use Formex.Ecto.ChangesetValidator

#   def build_form(form) do
#     form
#     |> add(:street, :text_input, label: "Street", validation: [:required])
#   end

#   def validator, do: Formex.Ecto.ChangesetValidator
# end

defmodule Formex.Ecto.Validator.ChangesetValidatorTest do
  use Formex.Ecto.NestedCase
  use Formex.Controller
  use Formex.Ecto.Controller
  alias Formex.Ecto.Validator.ChangesetValidatorTest.UserType

  test "basic" do
    params = %{"first_name" => "", "last_name" => "", "age" => "10"}
    form = create_form(UserType, %User{}, params)
    {:error, form} = insert_form_data(form)

    assert form.errors[:first_name] == ["can't be blank"]
    assert form.errors[:last_name] == ["give me your name!"]
    assert form.errors[:age] == ["you must be 13."]

    params = %{"first_name" => "a", "last_name" => "a", "age" => "20"}
    form = create_form(UserType, %User{}, params)
    {:ok, _} = insert_form_data(form)
  end
end
