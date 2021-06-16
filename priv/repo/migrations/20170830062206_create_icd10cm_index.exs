defmodule McodesPrep.Repo.Migrations.CreateIcd10cmIndex do
  use Ecto.Migration

  def change do
    create table(:icd10cm_index) do
      add :title, :string 
      add :main_term_text, :text
      add :main_term_jsonb, :map 
      add :title_tsv, :tsvector
      timestamps(inserted_at: :created_at, updated_at: false)
      
    end

  end
end
