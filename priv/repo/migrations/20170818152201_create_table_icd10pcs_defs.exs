defmodule McodesPrep.Repo.Migrations.CreateTableIcd10pcsDefs do
  use Ecto.Migration

  def change do
    create table(:icd10pcs_defs) do
      add :section, :string, size: 1
      add :section_title, :string, size: 100
      add :axis_code, :string, size: 1
      add :axis_title, :string, size: 250
      add :terms, :map
      add :title_tsv, :tsvector
      timestamps(inserted_at: :created_at, updated_at: false)
      #remove :created_at
    end

  end
end
