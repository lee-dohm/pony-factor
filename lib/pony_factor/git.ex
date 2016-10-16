require Logger

defmodule PonyFactor.Git do
  @moduledoc """
  Interfaces with Git to extract needed information from the repository.
  """

  @commit_pattern ~r/(?<hash>[0-9a-f]+)\s+(?<date>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [+-]\d{4})\s+(?<name>.+)/

  @doc """
  Clones the GitHub repository named by `[owner]/[repo]` into a temporary directory.

  Returns a tuple consisting of the path where the repository was cloned and the exit code of
  the clone operation.
  """
  def clone(nwo) do
    [_, repo] = Path.split(nwo)
    temp_dir = System.tmp_dir!
    target = Path.join(temp_dir, repo)
    url = create_url(nwo)

    Logger.info("Clone #{url} into #{target}")
    {_, exit_code} = System.cmd("git", ["clone", url, target])

    {target, exit_code}
  end

  @doc """
  Returns the list of commits as three-element tuples in the form
  `{sha, date_authored, author_name}` where:

  * `sha` is a String containing the shortened Git hash for the commit
  * `date_authored` is a String containing the
    [ISO8601-formatted](https://en.wikipedia.org/wiki/ISO_8601) date when the commit was authored
  * `author_name` is the display name of the author of the commit
  """
  def commit_list(target) do
    Logger.info("Get commit list")

    target
    |> commit_list_text
    |> split_commits
  end

  defp create_url(nwo), do: "https://github.com/#{nwo}.git"

  defp commit_list_text(target) do
    case System.cmd("git", ["log", "--format=%h %ai %an"], cd: target, stderr_to_stdout: true) do
      {output, 0} -> {:ok, output}
      {_, error_code} -> {:error, error_code}
    end
  end

  defp split_commits({:error, error_code}), do: {:error, error_code}

  defp split_commits({:ok, output}) do
    output
    |> String.split("\n")
    |> Enum.filter(fn(line) -> String.length(line) > 0 end)
    |> Enum.map(fn(line) ->
         captures = Regex.named_captures(@commit_pattern, line)

         {captures["hash"], captures["date"], captures["name"]}
       end)
  end
end
