defmodule Buildex.Poller.Api.ServiceTest do
  use ExUnit.Case, async: false
  use MecksUnit.Case

  alias Buildex.Poller.Repository.{Service, Github, GithubFake}
  alias Buildex.Common.Repos.Repo
  alias Buildex.Common.Tags.Tag
  alias Tentacat.Repositories.Tags

  defmock Tentacat.Repositories.Tags do
    def list(_, "elixir-lang", "elixir") do
      []
    end
  end

  mocked_test "calls github adapter" do
    repo = Repo.new("https://github.com/elixir-lang/elixir")
    assert {:ok, []} == Service.get_tags(Github, repo)
  end

  test "calls fake github adapter", %{repo: repo} do
    assert {:ok, tags} = Service.get_tags(GithubFake, repo)
    assert length(tags) == 21
    assert %Tag{name: "v1.7.2"} = hd(tags)
  end
end
