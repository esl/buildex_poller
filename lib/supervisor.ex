defmodule Buildex.Poller.PollerSupervisor do
  alias Buildex.Poller
  alias Buildex.Common.Repos.Repo
  alias Buildex.Poller.Config

  def start_child(%Repo{name: name} = repo) do
    pool_id = Config.get_connection_pool_id()

    adapter = setup_adapter(repo.adapter)

    Horde.Supervisor.start_child(Buildex.DistributedSupervisor, %{
      id: "poller_#{name}",
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
    %{name: name} = Repo.new(repository_url)

    Horde.Registry.lookup(Buildex.DistributedRegistry, name)
    |> case do
      :undefined ->
        {:error, "Couldn't find repository process."}

      [{pid, _value}] when is_pid(pid) ->
        Horde.Supervisor.terminate_child(Buildex.DistributedSupervisor, pid)
    end
  end

  defp setup_adapter(adapter) when is_atom(adapter), do: adapter

  defp setup_adapter(adapter) when is_binary(adapter) do
    Module.concat(["Buildex.Poller.Repository", Macro.camelize(adapter)])
  end
end
