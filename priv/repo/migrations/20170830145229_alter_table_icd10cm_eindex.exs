defmodule McodesPrep.Repo.Migrations.AlterTableIcd10cmEindex do
  use Ecto.Migration

  def change do
    alter table(:icd10cm_eindex) do
      remove :created_at
    end


  end
end
