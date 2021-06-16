defmodule McodesPrep.Repo.Migrations.AlterIcd10cmTableAddLtree do
  use Ecto.Migration
  # execute "CREATE EXTENSION ltree" # Enables Ltree action

  def change do
    execute("CREATE EXTENSION ltree",
            "DROP EXTENSION ltree")
  end
  
  def change do
    alter table(:icd10cm) do
      add :icd10cm_code_ltree, :ltree
    end
     create index(:icd10cm, [:icd10cm_code_ltree], using: :gist)
  end
end
