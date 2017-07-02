defmodule Formex.Ecto.TestRepo.Migrations.UserAge do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :age, :integer
    end
  end
end
