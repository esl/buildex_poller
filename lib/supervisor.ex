defmodule Buildex.Poller.PollerSupervisor do
  use DynamicSupervisor

  alias Buildex.Poller
  alias Buildex.Common.Repos.Repo
  alias Buildex.Poller.Config

  @spec start_link(keyword()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(args \\ []) do
    name = Keyword.get(args, :name, __MODULE__)
    DynamicSupervisor.start_link(__MODULE__, [], name: name)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(%Repo{} = repo) do
    pool_id = Config.get_connection_pool_id()

    adapter = setup_adapter(repo.adapter)

    DynamicSupervisor.start_child(__MODULE__, %{
      id: "poller_#{repo.name}",
      start: {Poller, :start_link, [{repo, adapter, pool_id}]},
      restart: :transient
    })
  end

  def start_child(%{
        repository_url: url,
        polling_interval: interval,
        adapter: adapter,
        github_token: token
      }) do
    Repo.new(url, interval * 1000, adapter, token)
    |> start_child()
  end

  def stop_child(repository_url) do
    repo = Repo.new(repository_url)

    try do
      repo.name
      |> String.to_existing_atom()
      |> Process.whereis()
      |> case do
        nil ->
          {:error, "Couldn't find repository process."}

        pid when is_pid(pid) ->
          DynamicSupervisor.terminate_child(__MODULE__, pid)
      end
    rescue
      _ -> {:error, "Couldn't find repository process."}
    end
  end

  defp setup_adapter(adapter) when is_atom(adapter), do: adapter

  defp setup_adapter(adapter) when is_binary(adapter) do
    Module.concat(["Buildex.Poller.Repository", Macro.camelize(adapter)])
  end
end
