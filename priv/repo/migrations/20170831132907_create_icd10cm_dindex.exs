defmodule McodesPrep.Repo.Migrations.CreateIcd10cmDindex do
  use Ecto.Migration

  def change do
    create table(:icd10cm_dindex) do
      add :title, :string, size: 250
      add :main_term, :map
      add :title_tsv, :tsvector
      timestamps(inserted_at: :created_at, updated_at: false)
    end


  end
end
