defmodule Formex.Ecto.TestRepo.Migrations.Comments do
  use Ecto.Migration

  def change do
    create table(:article_comments) do
      add :content, :string
      add :assoc_id, references(:articles)
    end

    create index(:article_comments, [:assoc_id])
  end
end
