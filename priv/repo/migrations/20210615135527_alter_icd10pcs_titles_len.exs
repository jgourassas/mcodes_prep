defmodule McodesPrep.Repo.Migrations.AlterIcd10pcsTitlesLen do
  use Ecto.Migration

  def change do
 alter table(:icd10pcs) do
   remove :device_title
   add :device_title, :string, size: 180
    end

  end
end
