defmodule Directed.Mixfile do
  use Mix.Project

  def project do
    [
      app: :directed,
      version: "0.0.1",
      elixir: "~> 0.15.0",
      deps: deps,
      test_coverage: [tool: ExCoveralls],
      build_per_environment: true
    ]
  end

  def application do
    [
      applications: [],
      mod: {Directed, []}
    ]
  end

  defp deps do
    [
      {:excoveralls, github: "parroty/excoveralls", only: [:dev, :test]}
    ]
  end
end
