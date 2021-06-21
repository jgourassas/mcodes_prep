defmodule McodesPrep.MixProject do
  use Mix.Project

  def project do
    [
      app: :mcodes_prep,
      version: "0.1.0",
      elixir: "~> 1.12",
      escript: escript(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

def escript() do
    [main_module: McodesPrep.Cli]
  end


  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger,
      :postgrex,
      :ecto,
      :sweet_xml,
      :iteraptor
      ],
      mod: {McodesPrep.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
       {:table_rex, "~> 3.1.1"},
      {:progress_bar, "~> 2.0.1", override: true},
       {:iteraptor, "~> 1.13.1", overide: true},
     # {:sweet_xml,  git: "https://github.com/awetzel/sweet_xml.git"},
      {:sweet_xml, "~> 0.6.6"},
      {:jason, "~> 1.2"},
      {:poison, "~> 4.0.1"},
      {:bunt, "~> 0.2.0"},

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
