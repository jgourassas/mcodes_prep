defmodule McodesPrep.Repo.Migrations.AlterIcd10pcsMainCodeToMap do
  use Ecto.Migration

  def change do
    alter table(:icd10pcs_index) do
      remove :main_term
      add :main_term, :map

    end

  end
end
