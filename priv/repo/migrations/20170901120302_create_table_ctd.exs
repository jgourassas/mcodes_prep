defmodule McodesPrep.Repo.Migrations.CreateTableCtd do
  use Ecto.Migration

  def change do
    create table(:ctd) do
add :diseasename, :string, size: 250
add :diseaseid, :string, size: 50
add :altdiseaseids, :string, size: 250
add :definition, :text
add :parentids, :string, size: 250
add :treenumbers, :text
add :parenttreenumbers, :text
add :synonyms , :text
add :slimmappings, :text
add :diseasename_tsv, :tsvector
add :synonyms_tsv, :tsvector
  timestamps(inserted_at: :inserted_on, updated_at: :updated_on, type: :date)
    end


  end
end
