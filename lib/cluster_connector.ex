defmodule Buildex.Poller.ClusterConnector do
  @moduledoc """
  Dynamic cluster membership
  """
  use GenServer

  require Logger
  alias Horde.Cluster

  @join_cluster_interval 5000

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def init(_) do
    cluster_nodes = get_nodes()

    :ok = join_cluster(cluster_nodes)
    schedule_join_cluster()
    {:ok, MapSet.new(cluster_nodes)}
  end

  def handle_info(:join_cluster, cluster_nodes) do
    new_cluster_nodes =
      get_nodes()
      |> MapSet.new()

    # only track removed nodes, when adding a new node to the cluster the other
    # node is in charge of updating the new cluster member list
    diff =
      cluster_nodes
      |> MapSet.difference(new_cluster_nodes)
      |> MapSet.to_list()

    if not Enum.empty?(diff) do
      new_cluster_nodes
      |> MapSet.to_list()
      |> join_cluster()
    end

    schedule_join_cluster()

    {:noreply, new_cluster_nodes}
  end

  defp schedule_join_cluster() do
    Process.send_after(self(), :join_cluster, @join_cluster_interval)
  end

  defp get_nodes() do
    [Node.self() | Node.list()]
    |> Enum.filter(fn node ->
      case Atom.to_string(node) do
        "poller" <> _ -> true
        _ -> false
      end
    end)
  end

  defp join_cluster(nodes) when is_list(nodes) do
    {supervisor_nodes, registry_nodes} =
      Enum.reduce(nodes, {[], []}, fn node, {supervisor_nodes, registry_nodes} ->
        {
          [{Buildex.DistributedSupervisor, node} | supervisor_nodes],
          [{Buildex.DistributedRegistry, node} | registry_nodes]
        }
      end)

    with :ok <- Cluster.set_members(Buildex.DistributedSupervisor, supervisor_nodes),
         :ok <- Cluster.set_members(Buildex.DistributedRegistry, registry_nodes) do
      :ok
    end
  end
end
