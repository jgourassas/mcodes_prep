defmodule McodesPrep.Repo.Migrations.AlterCtdAltdiseaseidsField do
  use Ecto.Migration

  def change do
    alter table(:ctd) do
      remove :altdiseaseids
      add  :altdiseaseids , :text
    end
  end
end
