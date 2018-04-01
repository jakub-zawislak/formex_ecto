defmodule Formex.Ecto.TestRepo.Migrations.UserDegrees do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :degrees, {:array, :string}
    end
  end
end
