defmodule McodesPrep.Repo.Migrations.CreateTableIcd10pcsIndex do
  use Ecto.Migration

  def change do
    create table(:icd10pcs_index) do
        add :title, :text
        add :main_term, :text
        add :title_tsv, :tsvector
        timestamps(inserted_at: :created_at, updated_at: false)

end
  end
end
