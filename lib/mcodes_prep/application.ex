defmodule McodesPrep.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {McodesPrep.Repo, []}
      # Starts a worker by calling: McodesPrep.Worker.start_link(arg)
      # {McodesPrep.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: McodesPrep.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
