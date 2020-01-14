defmodule Buildex.Poller.SetupWorker do
  use GenServer
  require Logger

  alias Buildex.Poller.PollerSupervisor
  alias Buildex.Poller.Config

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  def init(_) do
    send(self(), :after_init)
    {:ok, nil}
  end

  @impl true
  def handle_info(:after_init, state) do
    # TODO: keep trying if rpc call to get all repositories fails
    with {:ok, repositories} <- Config.get_database().get_all_repositories(),
         :ok <- start_repositories_workers(repositories) do
      {:noreply, state}
    else
      {:error, :nodedown} ->
        reconnect = Config.get_database_reconnection_interval()
        Logger.info("database node is down re-scheduling setup in #{reconnect} ms")
        # TODO: use backoff for reconnections
        Process.send_after(self(), :after_init, reconnect)
        {:noreply, state}

      {:error, reason} ->
        {:stop, reason, state}
    end
  end

  defp start_repositories_workers([]), do: :ok

  defp start_repositories_workers([repo | rest]) do
    repo
    |> PollerSupervisor.start_child()
    |> case do
      {:ok, _pid} ->
        start_repositories_workers(rest)

      {:error, {:already_started, _pid}} ->
        start_repositories_workers(rest)

      {:error, _} = error ->
        error
    end
  end
end
