defmodule McodesPrep.Repo.Migrations.CreateIcd10pcsTable do
  use Ecto.Migration
 def change do
    create table(:icd10pcs) do
      add :order_number, :integer
      add :icd10pcs_code, :string, size: 7
      add :icd10pcs_code_2, :string, size: 9
      add :icd10pcs_code_2_ltree, :string, size: 24
      add :is_header,:string , size: 1
      add :short_description,:string, size: 60
      add :long_description,:string, size: 250
      add :section,:string, size: 1
      add :section_title, :string, size: 100
      add :body_system, :string, size: 1
      add :body_system_title, :string, size: 100
      add :root_operation, :string, size: 1
      add :root_operation_title, :string, size: 100
      add :body_part, :string, size: 1
      add :body_part_title, :string, size: 100
      add :approach, :string, size: 1
      add :approach_title, :string, size: 100
      add :device, :string, size: 1
      add :device_title, :string, size: 100
      add :qualifier, :string, size: 1
      add :qualifier_title, :string, size: 100
      timestamps(inserted_at: :created_at, updated_at: false)
    end


  end#change

end
