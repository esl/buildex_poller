# defmodule Buildex.Poller.Integration.GithubTest do
#   use ExUnit.Case, async: false

#   alias Buildex.Poller.Repository.Github
#   alias Buildex.Common.Repos.Repo

#   @moduletag :integration

#   # flaky test: due to rate limiting from github, so we need to ensure we rather success
#   # or we ware rate-limited
#   @tag :integration
#   test "fetch all tags from repo" do
#     Repo.new("https://github.com/elixir-lang/elixir")
#     |> Github.get_tags()
#     |> case do
#       {:ok, tags} ->
#         refute Enum.empty?(tags)
#         assert Enum.find(tags, &(&1.name == "v1.7.2"))
#         assert Enum.find(tags, &(&1.name == "v1.0.0"))

#       {:error, :rate_limit, retry_in_seconds} ->
#         assert retry_in_seconds > 0
#     end
#   end
# end
