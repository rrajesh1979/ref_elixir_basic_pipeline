defmodule RefElixirBasicPipeline.MixProject do
  use Mix.Project

  def project do
    [
      app: :ref_elixir_basic_pipeline,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
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
      {:httpoison, "~> 1.8"}
    ]
  end

  defp escript do
    [main_module: RefElixir.BasicPipeline]
  end
end
