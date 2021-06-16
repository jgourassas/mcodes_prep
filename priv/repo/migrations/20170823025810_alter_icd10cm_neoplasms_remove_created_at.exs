defmodule McodesPrep.Repo.Migrations.AlterIcd10cmNeoplasmsRemoveCreatedAt do
  use Ecto.Migration

  def change do
    alter table(:icd10cm_neoplasms) do
      remove :created_at
    end

  end
end
