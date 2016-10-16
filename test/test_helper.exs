ExUnit.start(capture_log: true)

defmodule Helpers do
  def fixture_path(name), do: Path.join("./test/fixtures", name)
end
