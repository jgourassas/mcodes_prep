defmodule McodesPrep.Repo.Migrations.ChangeTableIcd10pcsIndexHstore do
  use Ecto.Migration
  def change do
    execute("CREATE EXTENSION hstore")
  end
  
  def change do
    alter table(:icd10pcs_index) do
      remove :main_term
      add :main_term, :hstore

    end
  end

end
