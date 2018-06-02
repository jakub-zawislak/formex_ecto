defmodule Formex.Ecto.BuilderTestType do
  use Formex.Type
  use Formex.Ecto.Type
  import Ecto.Changeset

  def build_form(form) do
    form
    |> add(:title, :text_input)
    |> add(:content, :textarea)
    |> add(:save, :submit)
  end

  def modify_changeset(changeset, _form) do
    changeset
    |> validate_length(:title, min: 3)
  end
end

defmodule Formex.BuilderTest do
  use Formex.Ecto.TestCase
  use Formex.Controller
  use Formex.Ecto.Controller
  alias Formex.Ecto.BuilderTestType
  alias Formex.Ecto.TestModel.Article
  alias Formex.Ecto.TestRepo

  test "create a form" do
    form = create_form(BuilderTestType, %Article{}, %{}, some: :data)
    assert Enum.at(form.items, 0).name == :title
    assert form.opts[:some] == :data
  end

  test "database insert" do
    params = %{"title" => "twoja", "content" => "stara"}
    form = create_form(BuilderTestType, %Article{}, params)

    {:ok, item} = insert_form_data(form)

    assert item.title == "twoja"
    assert item.content == "stara"
  end

  test "database update" do
    article = TestRepo.insert!(%Article{title: "asd", content: "szynka"})

    params = %{"content" => "cebula"}
    form = create_form(BuilderTestType, article, params)

    {:ok, item} = update_form_data(form)

    assert item.content == "cebula"
  end

  test "changeset error" do
    article = TestRepo.insert!(%Article{title: "asd", content: "szynka"})

    params = %{"title" => "as", "content" => "szynka"}
    form = create_form(BuilderTestType, article, params)

    {:error, form} = update_form_data(form)
  end
end
