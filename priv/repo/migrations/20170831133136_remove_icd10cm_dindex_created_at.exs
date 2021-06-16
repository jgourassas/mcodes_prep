defmodule McodesPrep.Repo.Migrations.RemoveIcd10cmDindexCreatedAt do
  use Ecto.Migration

  def change do
    alter table(:icd10cm_dindex) do
      remove :created_at
    end

  end
end
