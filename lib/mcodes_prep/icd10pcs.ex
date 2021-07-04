defmodule McodesPrep.Icd10pcs do
  use Ecto.Schema
  # This is the one that includes cast
  import Ecto.Changeset

  schema "icd10pcs" do
    field(:order_number, :integer)
    field(:icd10pcs_code, :string, size: 7)
    field(:icd10pcs_code_2_ltree, :string, size: 12)
    field(:is_header, :string, size: 1)
    field(:short_description, :string, size: 60)
    field(:long_description, :string, size: 250)
    field(:section, :string, size: 1)
    field(:section_title, :string, size: 1)
    field(:body_system, :string, size: 1)
    field(:body_system_title, :string, size: 100)
    field(:root_operation, :string, size: 1)
    field(:root_operation_title, :string, size: 100)
    field(:body_part, :string, size: 1)
    field(:body_part_title, :string, size: 100)
    field(:approach, :string, size: 1)
    field(:approach_title, :string, size: 100)
    field(:device, :string, size: 1)
    field(:device_title, :string, size: 180)
    field(:qualifier, :string, size: 1)
    field(:qualifier_title, :string, size: 100)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :order_number,
      :icd10pcs_code,
      :icd10pcs_code_2_ltree,
      :is_header,
      :short_description,
      :long_description,
      :section,
      :section_title,
      :body_system,
      :body_system_title,
      :root_operation,
      :root_operation_title,
      :body_part,
      :body_part_title,
      :approach,
      :approach_title,
      :device,
      :device_title,
      :qualifier,
      :qualifier_title
    ])
  end
end

## module
