defmodule McodesPrep.Repo.Migrations.AlterIcd10cmIndexRemoveCreatedAt do
  use Ecto.Migration

  def change do
    alter table(:icd10cm_index) do
      remove :created_at
    end


  end
end
