defmodule McodesPrep.Repo.Migrations.CreateIcd10cmNeoplasms do
  use Ecto.Migration

  def change do
    create table(:icd10cm_neoplasms) do
      add :title, :string, size: 250
      add :main_term, :map
      add :title_tsv, :tsvector
      timestamps(inserted_at: :created_at, updated_at: false)
    end

  end
end
