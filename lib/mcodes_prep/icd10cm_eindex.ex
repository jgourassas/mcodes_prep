defmodule McodesPrep.Icd10cmEindex do

  use Ecto.Schema
  import Ecto.Changeset # This is the one that includes cast
  schema "icd10cm_eindex" do
    field :title, :string
    field :main_term_text, :string
    field :main_term_jsonb, :map
    field :title_tsv, :string
  end#schema
  
   def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title,
                     :main_term_text,
                     :main_term_jsonb,
                     :title_tsv ])
                     
   end

  
  end#module


