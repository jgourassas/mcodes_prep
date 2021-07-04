defmodule McodesPrep.Icd10pcsDefs do
  use Ecto.Schema
  # This is the one that includes cast
  import Ecto.Changeset

  schema "icd10pcs_defs" do
    field(:section, :string)
    field(:section_title, :string)
    field(:axis_code, :string)
    field(:axis_title, :string)
    field(:terms, :map)
    field(:title_tsv, :string)
    field(:term_titles, :string)
    field(:term_includes, :string)
    field(:term_definition, :string)
    field(:term_explanation, :string)
  end

  # schema

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :section,
      :section_title,
      :axis_code,
      :axis_title,
      :terms,
      :title_tsv,
      :term_titles,
      :term_includes,
      :term_definition,
      :term_explanation
    ])
  end
end

# module
