defmodule McodesPrep.Repo.Migrations.AlterTableIcd10pcsIndexRemoveCreatedAt do
  use Ecto.Migration

  def change do
    alter table(:icd10pcs_index) do
      remove :created_at
    end

  end
end
