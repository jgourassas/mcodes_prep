defmodule McodesPrep.Repo.Migrations.CreateIcd10pcsAggregetes do
  use Ecto.Migration

  def change do
    create table(:icd10pcs_aggregates) do
      add :device, :string, size: 250
      add :operation, :text
      add :body_sys, :text
      add :parent_text, :string, size: 250
      add :parent_value, :string, size: 1
      add :device_tsv, :tsvector
      timestamps(inserted_at: :created_at, updated_at: false)
      #remove :created_at
    end

  end
end
