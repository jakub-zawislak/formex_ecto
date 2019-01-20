defmodule Formex.Ecto.TestRepo.Migrations.Avatar do
  use Ecto.Migration

  def change do
    create table(:user_avatars) do
      add :url, :string
      add :assoc_id, references(:users)
    end

    create index(:user_avatars, [:assoc_id])
  end
end
