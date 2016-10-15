require Logger

defmodule PonyFactor do
  @moduledoc """
  Calculates the [Pony Factor](https://ke4qqq.wordpress.com/2015/02/08/pony-factor-math/) of a GitHub
  repository.
  """

  @commit_percentage 0.5

  @doc """
  Calculates the Pony Factor of the `location`.

  The `location` can either be a GitHub `owner/repo` name or a path to a local repository if the
  `:directory` option is specified. If a GitHub repository is specified, the repo will be cloned
  to the local filesystem for the calculations and then deleted afterward.

  It returns a list of three-element tuples of the form `{name, date, commit_count}` where:

  * `name` is the display name of the contributor
  * `date` is the date of the latest commit from that contributor
  * `commit_count` is the number of commits that person has contributed

  The list is sorted from most commits to least.

  You can get the length of the list to determine the Pony Factor number.

  ### Pony Factor

  The Pony Factor of a repository is the smallest number of contributors that, when totalling the
  number of commits for each contributor, equals 50% or more of the commits in the repository.

  This is a measure of the "health" of a project based on the idea that a higher number means:

  * More people understand the codebase, increasing resiliency in the face of long-term contributor
    turnover
  * More people contributing significantly means that the codebase is more approachable

  ### Options

  The following options are supported:

  * `:directory` - Set to `true` to supply the path to a local repository as the location
  """
  def calculate(location, options \\ [])

  def calculate(path, directory: true), do: calculate_from_local_repo(path)

  def calculate(nwo, _) do
    {clone_dir, 0} = PonyFactor.Git.clone(nwo)

    pony_list = calculate_from_local_repo(clone_dir)

    File.rm_rf!(clone_dir)
    pony_list
  end

  def display({:error, message}) do
    IO.puts(message)
    exit({:shutdown, 1})
  end

  def display(pony_list) do
    Enum.each(pony_list, fn({name, date, count}) -> IO.puts("#{name}\t#{count}\t#{date}") end)

    IO.puts(nil)
    IO.puts("Pony Factor = #{Enum.count(pony_list)}")
  end

  defp calculate_from_local_repo(clone_dir) do
    commits = PonyFactor.Git.commit_list(clone_dir)
    commit_count = Enum.count(commits)

    Logger.info("Calculate Pony Factor")

    commits
    |> collect_committers
    |> sort_committers
    |> filter_committers
    |> pony(commit_count)
  end

  defp collect_committers(commits), do: collect_committers(%{}, commits)

  defp collect_committers(committers, []), do: committers
  defp collect_committers(committers, [{_, date, name} | commits]) do
    {_, new_committers} = Map.get_and_update(committers, name, fn
                            nil                     -> {name, {name, date, 1}}
                            {_, commit_date, count} -> {name, {name, max_date(date, commit_date), count + 1}}
                          end)

    collect_committers(new_committers, commits)
  end

  defp filter_committers(committers) do
    now = DateTime.utc_now
    year = Integer.to_string(now.year - 1)
    month = pad_date_part(now.month)
    day = pad_date_part(now.day)
    one_year_ago = "#{year}-#{month}-#{day}"

    Enum.filter(committers, fn({_, commit_date, _}) -> one_year_ago < commit_date end)
  end

  defp pad_date_part(part) do
    part
    |> Integer.to_string
    |> String.pad_leading(2, "0")
  end

  defp max_date(a, b) when a > b, do: a
  defp max_date(_, b), do: b

  defp pony(committers, commit_count) do
    pony(0, [], committers, commit_count * @commit_percentage)
  end

  defp pony(sum, list, _, count) when sum >= count, do: Enum.reverse(list)
  defp pony(sum, _, [], count),
    do: {:error, "Augmented Pony Factor undefined: only #{Float.round(sum / (count / @commit_percentage) * 100, 2)}% of commits are covered by committers who are still active"}
  defp pony(sum, list, [committer = {_, _, author_count} | committers], count),
    do: pony(sum + author_count, [committer | list], committers, count)

  defp sort_committers(committers) do
    committers
    |> Map.values
    |> Enum.sort_by(fn({_, _, count}) -> count end, &>=/2)
  end
end
