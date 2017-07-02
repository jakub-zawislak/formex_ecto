defmodule Formex.Ecto.SelectAssoc.GroupFieldTestType do
  use Formex.Type
  use Formex.Ecto.Type
  require Formex.Ecto.CustomField.SelectAssoc

  def build_form(form) do
    form
    |> add(:user_id, Formex.Ecto.CustomField.SelectAssoc, validation: [:required],
      choice_label: fn user -> user.last_name<>" "<>user.first_name end,
      group_by: :last_name
    )
  end
end

defmodule Formex.Ecto.SelectAssoc.GroupAssocTestType do
  use Formex.Type
  use Formex.Ecto.Type
  require Formex.Ecto.CustomField.SelectAssoc

  def build_form(form) do
    form
    |> add(:user_id, Formex.Ecto.CustomField.SelectAssoc, validation: [:required],
      choice_label: fn user -> user.last_name<>" "<>user.first_name end,
      group_by: :department
    )
  end
end

defmodule Formex.Ecto.SelectAssoc.GroupAssocFieldTestType do
  use Formex.Type
  use Formex.Ecto.Type
  require Formex.Ecto.CustomField.SelectAssoc

  def build_form(form) do
    form
    |> add(:user_id, Formex.Ecto.CustomField.SelectAssoc, validation: [:required],
      choice_label: fn user -> user.last_name<>" "<>user.first_name end,
      group_by: [:department, :id]
    )
  end
end

defmodule Formex.Ecto.SelectAssoc.ChoiceGroupTest do
  use Formex.Ecto.SelectAssocCase
  alias Formex.Ecto.SelectAssoc.GroupFieldTestType
  alias Formex.Ecto.SelectAssoc.GroupAssocTestType
  alias Formex.Ecto.SelectAssoc.GroupAssocFieldTestType

  test "group by a field" do
    insert_users()

    form = create_form(GroupFieldTestType, %Article{})

    choice_groups = Enum.at(form.items, 0).data[:choices]
    choice_group  = Enum.at(choice_groups, 0)

    {group_label, choices} = choice_group

    assert group_label == "Cebula"
    assert choices |> Enum.at(0) |> elem(0) == "Cebula Jan"
    assert Enum.count(choices) == 2
  end

  test "group by an assoc" do
    insert_users()

    form = create_form(GroupAssocTestType, %Article{})

    choice_groups = Enum.at(form.items, 0).data[:choices]
    choice_group  = Enum.at(choice_groups, 0)

    {group_label, choices} = choice_group

    assert group_label == "Accounting"
    assert choices |> Enum.at(0) |> elem(0) == "Kowalska Grażyna"
    assert Enum.count(choices) == 2
  end

  test "group by a field of an assoc" do
    insert_users()

    form = create_form(GroupAssocFieldTestType, %Article{})

    choice_groups = Enum.at(form.items, 0).data[:choices]
    choice_group  = Enum.at(choice_groups, 0)

    {group_label, _} = choice_group

    assert is_integer(group_label)
  end

end
