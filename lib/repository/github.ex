defmodule Buildex.Poller.Repository.Github do
  @moduledoc """
  Repository Adapter for Github's API
  """
  @behaviour Buildex.Poller.Repository.Adapter

  alias Tentacat.Client
  alias Tentacat.Repositories.Tags
  alias Buildex.Common.Repos.Repo
  alias Buildex.Common.Tags.Tag
  alias Buildex.Poller.Config

  @doc """
  Get all tags/releases from a Github repository

  ## Args:

  * `repo` - repository abstraction referencing a Github repository

  ## Return Values:

    * `{:ok, tags}` - ok tuple with the repo tags
    * `{:error, :rate_limit, milli_seconds}` - when we are rate limited by
    github we should retry in the given milli_seconds
    * `{:error, reason}` - any other error returned by either Tentacat
    or HTTPoison
  """
  @spec get_tags(Repo.t()) ::
          {:ok, list(Tag.t())} | {:error, :rate_limit, pos_integer()} | {:error, map()}
  def get_tags(%{owner: owner, name: name, github_token: token}) do
    try do
      token
      |> new()
      |> Tags.list(owner, name)
      |> handle_tags_reponse()
    rescue
      # Tentacat uses poison `request!` method so it blows up on any kind of
      # error e.g connection timeout, and this should not crash any process,
      # so we need to rescue exceptions and return an error tuple
      error in HTTPoison.Error ->
        {:error, error}
    end
  end

  # TODO: FIX specs fo this function
  # RELATED ISSUE: https://github.com/edgurgel/tentacat/issues/144
  # @spec handle_tags_reponse(Tentacat.response()) ::
  #         {:ok, Tag.t()} | {:error, map()} | {:error, :rate_limit, pos_integer()}
  # multiple success clauses due to: https://github.com/edgurgel/tentacat/issues/144
  defp handle_tags_reponse({:ok, json_body, _httpoison_response}) do
    {:ok, map_tags(json_body)}
  end

  defp handle_tags_reponse({200, json_body, _httpoison_response}) do
    {:ok, map_tags(json_body)}
  end

  defp handle_tags_reponse({403, error_body, %{headers: headers}}) do
    {_, rate_limit_remaining} = List.keyfind(headers, "X-RateLimit-Remaining", 0)
    rate_limit_remaining = String.to_integer(rate_limit_remaining, 10)

    if rate_limit_remaining > 0 do
      # error different than a rate-limit error
      {:error, error_body}
    else
      {_, rate_limit_reset} = List.keyfind(headers, "X-RateLimit-Reset", 0)
      rate_limit_reset = String.to_integer(rate_limit_reset, 10)
      rate_limit_reset_dt = DateTime.from_unix!(rate_limit_reset)
      now = DateTime.utc_now()
      retry_in_milli_seconds = DateTime.diff(rate_limit_reset_dt, now) * 1000
      {:error, :rate_limit, retry_in_milli_seconds}
    end
  end

  defp handle_tags_reponse({_, error_body, _httpoison_response}), do: {:error, error_body}

  # multiple success clauses due to: https://github.com/edgurgel/tentacat/issues/144
  defp handle_tags_reponse(json_body) do
    {:ok, map_tags(json_body)}
  end

  @spec new(String.t()) :: Tentacat.Client.t()
  defp new(nil) do
    case Config.get_github_access_token() do
      nil -> Client.new()
      auth -> Client.new(auth)
    end
  end

  defp new(token) when is_binary(token), do: Client.new(%{access_token: token})

  defp map_tags(json_body) do
    Enum.map(json_body, &Tag.new/1)
  end
end
