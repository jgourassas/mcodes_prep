defmodule McodesPrep.Repo.Migrations.AlterIcd10pcsTableDropCreatedAt do
  use Ecto.Migration

  def change do
    alter table(:icd10pcs) do
      remove :created_at
    end
  end

end
