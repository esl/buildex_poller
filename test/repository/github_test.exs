defmodule Buildex.Poller.Api.GithubTest do
  use ExUnit.Case, async: false
  import Mock

  alias Buildex.Poller.Repository.Github
  alias Buildex.Common.Repos.Repo
  alias Buildex.Common.Tags.Tag
  alias Tentacat.Repositories.Tags

  setup do
    repo = Repo.new("https://github.com/elixir-lang/elixir")
    {:ok, repo: repo}
  end

  test "gets all tags from a repo", %{repo: repo} do
    lambda_list = fn _, _, _ ->
      [
        %{
          "commit" => %{
            "sha" => "2b338092b6da5cd5101072dfdd627cfbb49e4736",
            "url" =>
              "https://api.github.com/repos/elixir-lang/elixir/commits/2b338092b6da5cd5101072dfdd627cfbb49e4736"
          },
          "name" => "v1.7.2",
          "node_id" => "MDM6UmVmMTIzNDcxNDp2MS43LjI=",
          "tarball_url" => "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.7.2",
          "zipball_url" => "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.7.2"
        },
        %{
          "commit" => %{
            "sha" => "8aab53b941ee955f005e7b4e08c333f0b94c48b7",
            "url" =>
              "https://api.github.com/repos/elixir-lang/elixir/commits/8aab53b941ee955f005e7b4e08c333f0b94c48b7"
          },
          "name" => "v1.7.1",
          "node_id" => "MDM6UmVmMTIzNDcxNDp2MS43LjE=",
          "tarball_url" => "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.7.1",
          "zipball_url" => "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.7.1"
        },
        %{
          "commit" => %{
            "sha" => "06e5ec2d4c628e57440b0a393e4efa98e7226173",
            "url" =>
              "https://api.github.com/repos/elixir-lang/elixir/commits/06e5ec2d4c628e57440b0a393e4efa98e7226173"
          },
          "name" => "v1.7.0",
          "node_id" => "MDM6UmVmMTIzNDcxNDp2MS43LjA=",
          "tarball_url" => "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.7.0",
          "zipball_url" => "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.7.0"
        }
      ]
    end

    with_mock Tags, list: lambda_list do
      assert {:ok, tags} = Github.get_tags(repo)
      assert length(tags) == 3
      assert %Tag{name: "v1.7.2"} = hd(tags)
    end
  end

  test "returns error tuple when failed to fetch tags", %{repo: repo} do
    lambda_list = fn _, _, _ ->
      {404, %{"message" => "Repository not found."},
       %HTTPoison.Response{status_code: 404, body: %{"message" => "Repository not found."}}}
    end

    with_mock Tags, list: lambda_list do
      assert {:error, %{"message" => "Repository not found."}} == Github.get_tags(repo)
    end
  end

  test "returns error tuple with retry interval when rate limited from to fetching tags", %{
    repo: repo
  } do
    now = DateTime.utc_now()
    in_1_hour = DateTime.to_unix(now) + 60 * 60

    lambda_list = fn _, _, _ ->
      {403, %{"message" => "Repository not found."},
       %HTTPoison.Response{
         status_code: 403,
         body: %{"message" => "Repository not found."},
         headers: [
           {"X-RateLimit-Remaining", "0"},
           {"X-RateLimit-Reset", "#{in_1_hour}"}
         ]
       }}
    end

    with_mock Tags, list: lambda_list do
      assert {:error, :rate_limit, retry} = Github.get_tags(repo)
      # sometimes the retry interval returns 3_600_000, 3_590_000, ... due to timing
      assert retry <= 3_600_000 and retry > 3_590_000
    end
  end

  test "returns error tuple when posion raises and exception", %{
    repo: repo
  } do
    error = %HTTPoison.Error{id: nil, reason: :timeout}

    lambda_list = fn _, _, _ ->
      raise error
    end

    with_mock Tags, list: lambda_list do
      assert {:error, ^error} = Github.get_tags(repo)
    end
  end

  test "returns error tuple when forbidden to fetch tags with a different reason than rate limiting",
       %{repo: repo} do
    payload_response = %{
      "message" =>
        "You have triggered an abuse detection mechanism and have been temporarily blocked from content creation. Please retry your request again later.",
      "documentation_url" => "https://developer.github.com/v3/#abuse-rate-limits"
    }

    lambda_list = fn _, _, _ ->
      {404, payload_response,
       %HTTPoison.Response{
         status_code: 404,
         body: payload_response,
         headers: [
           {"X-RateLimit-Remaining", 1000}
         ]
       }}
    end

    with_mock Tags, list: lambda_list do
      assert {:error, ^payload_response} = Github.get_tags(repo)
    end
  end
end
