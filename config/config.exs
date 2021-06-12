import Config

config :mcodes_prep, McodesPrep.Repo,
  database: "mcodes_prep_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

  config :mcodes_prep,
      ecto_repos: [McodesPrep.Repo]

config :elixir, ansi_enabled: true
config :logger, level: :warn


