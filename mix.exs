defmodule RefElixirBasicPipeline.MixProject do
  use Mix.Project

  def project do
    [
      app: :ref_elixir_basic_pipeline,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_add_deps: :apps_direct,
        plt_add_apps: [:wx],
        plt_ignore_apps: [:mnesia]
      ],
      escript: escript(),
      # Docs
      name: :ref_elixir_basic_pipeline,
      source_url: "https://github.com/rrajesh1979/ref_elixir_basic_pipeline",
      docs: [
        # The main page in the docs
        main: "RefElixir.BasicPipeline",
        # logo: "path/to/logo.png",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {RefElixirBasicPipeline.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}

      # Elixir documentation generation tool
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},

      # Dev / Test Libraries
      # Static code analysis tool with a focus on code consistency and teaching.
      {:credo, "~> 1.6"},
      # Dialyzer is a static analysis tool
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},

      # Library to make HTTP calls
      {:httpoison, "~> 1.8"}
    ]
  end

  defp escript do
    [main_module: RefElixir.BasicPipeline]
  end
end
