defmodule McodesPrep.Repo.Migrations.CreateNdcPackages do
  use Ecto.Migration

  def change do
    create table(:ndc_packages) do
      add :productid, :text
      add :productndc, :text
      add :ndcpackagecode, :text
      add :packagedescription, :text
      add :startmarketingdate, :text
      add :endmarketingdate, :text
      add :ndc_exclude_flag, :text
      add :sample_package, :text
      #add(:ndc_product_id, references(:ndc_products, on_delete: :delete_all))

    end

  end
end
