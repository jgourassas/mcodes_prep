defmodule McodesPrep.Icd10pcsAggegates do
  use Ecto.Schema
  # This is the one that includes cast
  import Ecto.Changeset

  schema "icd10pcs_aggregates" do
    field(:device, :string)
    field(:operation, :string)
    field(:body_sys, :string)
    field(:parent_text, :string)
    field(:parent_value, :string)
  end

  # schema

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :device,
      :operation,
      :body_sys,
      :parent_text,
      :parent_value
    ])
  end
end

# module
