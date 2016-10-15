defmodule PonyFactor.CLI do
  @moduledoc """
  Provides the command-line interface (CLI) for the Pony Factor tool.
  """

  def main(_args) do
    {options, [location | _]} = OptionParser.parse!(System.argv, strict: [directory: :boolean])

    location
    |> PonyFactor.calculate(options)
    |> PonyFactor.display
  end
end
