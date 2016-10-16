defmodule PonyFactorTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  doctest PonyFactor

  defmodule MockKernel do
    def exit(value), do: value
  end

  test "when display is passed an error it issues a shutdown" do
    capture_io(fn ->
      assert PonyFactor.display({:error, "test"}, MockKernel) == {:shutdown, 1}
    end)
  end

  test "when display is passed an error it prints the error" do
    fun = fn -> PonyFactor.display({:error, "test"}, MockKernel) end

    assert capture_io(fun) == "test\n"
  end
end
