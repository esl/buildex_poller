defmodule Buildex.Poller.Repository.GithubFake do
  @behaviour Buildex.Poller.Repository.Adapter

  alias Buildex.Common.Repos.Repo

  @new_tags Poison.decode!(File.read!("test/github_fake.json"), as: [%Tag{name: nil}])BBBB

  @spec get_tags(Repo.t()) ::
          {:ok, list(Tag.t())} | {:error, :rate_limit, pos_integer()} | {:error, any()}
  def get_tags(%{owner: "rate-limit"}) do
    {:error, :rate_limit, 50}
  end

  def get_tags(%{owner: "404"}) do
    {:error, :not_found}
  end

  def get_tags(%{owner: "2-new-tags"}) do
    {:ok, Enum.take(@new_tags, 2)}
  end

  def get_tags(%{owner: "new-tag"}) do
    {:ok, Enum.take(@new_tags, 1)}
  end

  def get_tags(%{owner: "no-tags"}) do
    {:ok, []}
  end

  def get_tags(_) do
    {:ok, @new_tags}
  end
end
