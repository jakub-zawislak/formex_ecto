defmodule Formex.Ecto.BuilderTestType do
  use Formex.Type
  use Formex.Ecto.Type

  def build_form(form) do
    form
    |> add(:title, :text_input)
    |> add(:content, :textarea)
    |> add(:visible, :checkbox, required: false)
    |> add(:save, :submit)
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
    form = create_form(BuilderTestType, %Article{}, %{}, [some: :data])
    assert Enum.at(form.items, 0).name == :title
    assert form.opts[:some] == :data
  end

  test "database insert" do
    params = %{"title" => "twoja", "content" => "stara"}
    form = create_form(BuilderTestType, %Article{}, params)

    {:ok, _} = insert_form_data(form)
  end

  test "database update" do

    article = TestRepo.insert!(%Article{title: "asd", content: "szynka"})

    params = %{"content" => "cebula"}
    form = create_form(BuilderTestType, article, params)

    {:ok, _} = update_form_data(form)
  end
end
