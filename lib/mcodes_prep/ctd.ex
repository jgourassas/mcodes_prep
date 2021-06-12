defmodule McodesPrep.Ctd do

  use Ecto.Schema
  import Ecto.Changeset # This is the one that includes cast
  schema "ctd" do
field :diseasename, :string
field :diseaseid,  :string
field :altdiseaseids,  :string
field :definition, :string
field :parentids,  :string
field :treenumbers, :string
field :parenttreenumbers,:string
field :synonyms,:string
field :slimmappings,:string
  end#schema

   def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
         :diseasename,       
 :diseaseid,        
 :altdiseaseids,   
 :definition,     
 :parentids,     
 :treenumbers,  
 :parenttreenumbers, 
 :synonyms,         
 :slimmappin,  
        ])


   end


  end#module


