defmodule McodesPrep.Repo.Migrations.AddIcd10cmLongDescTsv do
  use Ecto.Migration

  def change do
    alter table(:icd10cm) do
      add :long_description_tsv, :tsvector
    end
 
  end
end
