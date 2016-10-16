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

  test "when display is passed a single list, it displays an Augmented Pony Factor" do
    fun = fn -> PonyFactor.display([{"Name", "Date", "Count"}]) end

    assert capture_io(fun) == """
                              Name\tCount\tDate

                              Augmented Pony Factor = 1
                              """
  end

  test "when display is passed a list and a tuple of two numbers, it displays a message and the Pony Factor" do
    fun = fn -> PonyFactor.display({[{"Name", "Date", "Count"}], {10, 100}}) end

    assert capture_io(fun) == """
                              Augmented Pony Factor is undefined: only 5.0% of commits are covered by committers who are still active

                              Name\tCount\tDate

                              Pony Factor = 1
                              """
  end
end
