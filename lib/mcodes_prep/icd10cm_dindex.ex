defmodule McodesPrep.Icd10cmDindex do

  use Ecto.Schema
  import Ecto.Changeset # This is the one that includes cast
 schema "icd10cm_dindex" do
    field :title, :string, size: 250
    field :main_term, :map
    field :title_tsv, :string
  end#schema
  
   def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title,
                     :main_term,
                     :title_tsv ])
                     
   end


################
end#Module


