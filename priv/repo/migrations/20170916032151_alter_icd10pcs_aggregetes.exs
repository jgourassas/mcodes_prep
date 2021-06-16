defmodule McodesPrep.Repo.Migrations.AlterIcd10pcsAggregetes do
  use Ecto.Migration

  def change do
    alter table(:icd10pcs_aggregates) do
      remove :created_at

    end

  end
end
