defmodule PonyFactor.Mixfile do
  use Mix.Project

  @version String.trim(File.read!("VERSION"))

  def project do
    [
      app: :pony_factor,
      version: @version,
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      escript: escript,

      # Docs
      name: "PonyFactor",
      source_url: "https://github.com/lee-dohm/pony-factor",
      homepage_url: "https://github.com/lee-dohm/pony-factor",
      docs: docs
    ]
  end

  def application do
    [
      applications: [:logger, :timex]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.14", only: :dev},
      {:timex, "~> 3.0"}
    ]
  end

  defp docs do
    [
      main: "PonyFactor",
      extras: [
        "LICENSE.md",
        "README.md"
      ]
    ]
  end

  defp escript do
    [
      main_module: PonyFactor.CLI
    ]
  end
end
