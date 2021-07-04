defmodule McodesPrep.Repo do
  use Ecto.Repo,
    otp_app: :mcodes_prep,
    adapter: Ecto.Adapters.Postgres
end
