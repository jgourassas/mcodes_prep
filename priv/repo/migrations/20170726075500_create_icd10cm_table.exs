defmodule McodesPrep.Repo.Migrations.CreateIcd10cmTable do
  use Ecto.Migration
  def change do
    create table(:icd10cm) do
      add :order_number, :integer
      add :icd10cm_code, :string, size: 7
      add :icd10cm_code_2, :string, size: 9
      add :icd10cm_code_2_ltree, :string, size: 12
      add :is_header,:string , size: 1
      add :short_description,:string, size: 60
      add :long_description,:string, size: 250
      add :includes,:text
      add :inclusionterm,:text
      add :excludes1,:text
      add :excludes2, :text
      add :codefirst, :text
      add :codealso, :text
      add :useadditionalcode,:text
      add :chapter_name, :integer
      add :chapter_description,:text
      add :section_id,:string, size: 10
      add :section_description,:text
      add :is_category,:string, size: 1
      add :is_subcategory,:string, size: 1
      timestamps(inserted_at: :created_at, updated_at: false)
    end
  end


end
