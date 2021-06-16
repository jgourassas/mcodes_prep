defmodule McodesPrep.Repo.Migrations.RemoveDateFromCtd do
  use Ecto.Migration

  def change do
    alter table(:ctd) do
      remove :inserted_on
      remove :updated_on
    end


  end
end
