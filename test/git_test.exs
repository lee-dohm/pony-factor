alias PonyFactor.Git

defmodule PonyFactor.Git.Test do
  use ExUnit.Case
  doctest PonyFactor.Git

  test "getting commit list on empty repo returns an error" do
    assert {:error, _} = Git.commit_list(Helpers.fixture_path("empty-repo.git"))
  end

  test "getting commit list on repo with one commit returns a length one list" do
    assert Enum.count(Git.commit_list(Helpers.fixture_path("one-commit.git"))) == 1
  end

  test "getting commit list on repo with one commit returns a properly formatted list" do
    assert Git.commit_list(Helpers.fixture_path("one-commit.git")) == [{"952ee8d", "2016-10-15 16:26:48 -0700", "Lee Dohm"}]
  end
end
