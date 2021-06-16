defmodule McodesPrep.Repo.Migrations.AlterIcd10pcsDefsAddFields do
  use Ecto.Migration

  def change do
    alter table(:icd10pcs_defs) do
      add :term_titles, :map
      add :term_includes, :map
      add :term_definition, :text
      add :term_explanation, :text 
     end
  end
end
