defmodule McodesPrep.Icd10cm do
  use Ecto.Schema
  # This is the one that includes cast
  import Ecto.Changeset
  # import Ecto.Query

  schema "icd10cm" do
    field(:order_number, :integer)
    field(:icd10cm_code, :string, size: 7)
    field(:icd10cm_code_2, :string, size: 9)
    field(:icd10cm_code_2_ltree, :string, size: 12)
    field(:is_header, :string, size: 1)
    field(:short_description, :string, size: 60)
    field(:long_description, :string, size: 250)
    field(:includes, :string)
    field(:inclusionterm, :string)
    field(:excludes1, :string)
    field(:excludes2, :string)
    field(:codefirst, :string)
    field(:codealso, :string)
    field(:useadditionalcode, :string)
    field(:chapter_name, :integer)
    field(:chapter_description, :string)
    field(:section_id, :string, size: 10)
    field(:section_description, :string)
    field(:is_category, :string, size: 1)
    field(:is_subcategory, :string, size: 1)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(
      params,
      [
        :order_number,
        :icd10cm_code,
        :icd10cm_code_2,
        :icd10cm_code_2_ltree,
        :is_header,
        :short_description,
        :long_description,
        :includes,
        :inclusionterm,
        :excludes1,
        :excludes2,
        :codefirst,
        :codealso,
        :useadditionalcode,
        :chapter_name,
        :chapter_description,
        :section_id,
        :section_description,
        :is_category,
        :is_subcategory
      ]
      # |> validate_required([:icd10cm_code_2])
    )
  end

  ####################
end
