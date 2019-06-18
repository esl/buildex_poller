defmodule Buildex.Poller.Cluster.Strategy.EpmdAutoHeal do
  use GenServer
  use Cluster.Strategy

  alias Cluster.Strategy
  alias Cluster.Strategy.State

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl GenServer
  def init(args) do
    [%State{config: config} = state] = args

    Keyword.get(config, :hosts, [])
    |> connect_nodes(state)

    schedule_self_heal()
    {:ok, state}
  end

  @impl GenServer
  def handle_info(:self_heal, %State{config: config} = state) do
    connected_nodes = Node.list()

    Keyword.get(config, :hosts, [])
    |> List.delete(Node.self())
    |> Kernel.--(connected_nodes)
    |> connect_nodes(state)

    schedule_self_heal()
    {:noreply, state}
  end

  defp schedule_self_heal() do
    Process.send_after(self(), :self_heal, 5000)
  end

  defp connect_nodes([], _), do: :ok

  defp connect_nodes(nodes, state) when is_list(nodes) do
    Strategy.connect_nodes(state.topology, state.connect, state.list_nodes, nodes)
    :ok
  end
end
