defmodule McodesPrep.Icd10pcsIndex do
  use Ecto.Schema
  # This is the one that includes cast
  import Ecto.Changeset

  schema "icd10pcs_index" do
    field(:title, :string)
    field(:main_term, :map)
    field(:title_tsv, :string)
  end

  # schema

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :main_term, :title_tsv])
  end
end

# module
