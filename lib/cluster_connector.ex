defmodule Buildex.Poller.ClusterConnector do
  use GenServer

  require Logger

  alias Buildex.Poller.Config

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def init(_) do
    cluster_nodes = Config.get_nodes()

    cluster_nodes
    |> List.delete(Node.self())
    |> connect_nodes()

    :ok = join_cluster(cluster_nodes)

    schedule_self_heal()

    {:ok, cluster_nodes}
  end

  def handle_info(:self_heal, cluster_nodes) do
    connected_nodes = Node.list()

    cluster_nodes_not_connected =
      cluster_nodes
      |> List.delete(Node.self())
      |> Kernel.--(connected_nodes)

    if not Enum.empty?(cluster_nodes_not_connected) do
      cluster_nodes_not_connected |> connect_nodes()
      join_cluster(cluster_nodes)
    end

    schedule_self_heal()
    {:noreply, cluster_nodes}
  end

  defp schedule_self_heal() do
    Process.send_after(self(), :self_heal, 5000)
  end

  defp connect_nodes(nodes) do
    for node <- nodes, do: Node.connect(node)
  end

  defp join_cluster(nodes) when is_list(nodes) do
    {supervisor_nodes, registry_nodes} =
      Enum.reduce(nodes, {[], []}, fn node, {supervisor_nodes, registry_nodes} ->
        {
          [{Buildex.DistributedSupervisor, node} | supervisor_nodes],
          [{Buildex.DistributedRegistry, node} | registry_nodes]
        }
      end)

    with :ok <- Horde.Cluster.set_members(Buildex.DistributedSupervisor, supervisor_nodes),
         :ok <- Horde.Cluster.set_members(Buildex.DistributedRegistry, registry_nodes) do
      :ok
    end
  end
end
