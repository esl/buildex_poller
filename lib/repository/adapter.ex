defmodule Buildex.Poller.Repository.Adapter do
  alias Buildex.Common.Repos.Repo
  alias Buildex.Common.Tags.Tag

  @callback get_tags(Repo.t()) ::
              {:ok, list(Tag.t())} | {:error, :rate_limit, pos_integer()} | {:error, any()}
end
