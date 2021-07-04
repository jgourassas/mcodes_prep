defmodule McodesPrep.Icd10cmIndex do
  use Ecto.Schema
  # This is the one that includes cast
  import Ecto.Changeset

  schema "icd10cm_index" do
    field(:title, :string)
    field(:main_term_text, :string)
    field(:main_term_jsonb, :map)
    field(:title_tsv, :string)
  end

  # schema

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :main_term_text, :main_term_jsonb, :title_tsv])
  end
end

# module
