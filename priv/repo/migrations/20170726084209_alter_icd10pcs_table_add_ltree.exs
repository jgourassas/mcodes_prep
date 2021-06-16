defmodule McodesPrep.Repo.Migrations.AlterIcd10pcsTableAddLtree do
  use Ecto.Migration

  def change do
    alter table(:icd10pcs) do
      add :icd10pcs_code_ltree, :ltree
    end
  end

end
