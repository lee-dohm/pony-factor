ExUnit.start()

defmodule Helpers do
  def fixture_path(name), do: Path.join("./test/fixtures", name)
end
