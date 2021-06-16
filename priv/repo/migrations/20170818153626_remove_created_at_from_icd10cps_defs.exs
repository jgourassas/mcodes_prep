defmodule McodesPrep.Repo.Migrations.RemoveCreatedAtFromIcd10cpsDefs do
  use Ecto.Migration

  def change do
 alter table(:icd10pcs_defs) do
      remove :created_at
    end

  end
end
