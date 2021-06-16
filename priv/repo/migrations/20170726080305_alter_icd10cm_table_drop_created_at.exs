defmodule McodesPrep.Repo.Migrations.AlterIcd10cmTableDropCreatedAt do
  use Ecto.Migration

  def change do
    alter table(:icd10cm) do
      remove :created_at
    end
  end

end
