defmodule McodesPrep.Repo.Migrations.RemoveTsvectorsFromCtd do
  use Ecto.Migration

  def change do
    alter table(:ctd) do
      remove :diseasename_tsv
      remove :synonyms_tsv 
    end


  end
end
