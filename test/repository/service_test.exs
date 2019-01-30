defmodule Buildex.Poller.Api.ServiceTest do
  use ExUnit.Case, async: false
  import Mock

  alias Buildex.Poller.Repository.{Service, Github, GithubFake}
  alias Buildex.Common.Repos.Repo
  alias Buildex.Common.Tags.Tag
  alias Tentacat.Repositories.Tags

  setup do
    repo = Repo.new("https://github.com/elixir-lang/elixir")
    {:ok, repo: repo}
  end

  test "calls real github adapter", %{repo: repo} do
    lambda_list = fn _, _, _ ->
      []
    end

    with_mock Tags, list: lambda_list do
      assert {:ok, []} == Service.get_tags(Github, repo)
    end
  end

  test "calls fake github adapter", %{repo: repo} do
    assert {:ok, tags} = Service.get_tags(GithubFake, repo)
    assert length(tags) == 21
    assert %Tag{name: "v1.7.2"} = hd(tags)
  end
end
