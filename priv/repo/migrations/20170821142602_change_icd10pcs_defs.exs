defmodule McodesPrep.Repo.Migrations.ChangeIcd10pcsDefs do
  use Ecto.Migration

  def change do
    alter table(:icd10pcs_defs) do
      remove :term_titles
      remove :term_includes
      add :term_titles, :text
      add :term_includes, :text
    end

  end
end
