defmodule Buildex.Poller.SetupWorkerTest do
  use ExUnit.Case, async: false
  import Mox

  alias Buildex.Poller
  alias Buildex.Poller.{SetupWorker, PollerSupervisor}
  alias Buildex.Poller.Repository.GithubFake

  # Make sure mocks are verified when the test exits
  setup :set_mox_global
  setup :verify_on_exit!

  def wait_for(timeout \\ 1000, f)
  def wait_for(0, _), do: {:error, "Timeout waiting for a poller worker to be created."}

  def wait_for(timeout, f) do
    if f.() do
      :ok
    else
      :timer.sleep(10)
      wait_for(timeout - 10, f)
    end
  end

  setup do
    Application.put_env(:buildex_poller, :database, Buildex.Common.Service.MockDatabase)
    Application.put_env(:buildex_poller, :rabbitmq_conn_pool, pool_id: :random)
  end

  # Silence GenServer stop
  @tag capture_log: true
  test "couldn't get repositories" do
    Buildex.Common.Service.MockDatabase
    |> expect(:get_all_repositories, fn ->
      {:error, :badrpc}
    end)

    pid = start_supervised!(SetupWorker)
    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, :process, ^pid, :badrpc}
  end

  test "couldn't get repositories - database node is down" do
    Buildex.Common.Service.MockDatabase
    |> expect(:get_all_repositories, fn ->
      {:error, :nodedown}
    end)

    pid = start_supervised!(SetupWorker)
    ref = Process.monitor(pid)
    refute_receive {:DOWN, ^ref, :process, ^pid, :nodedown}
  end

  test "start repositories successfully" do
    Buildex.Common.Service.MockDatabase
    |> expect(:get_all_repositories, fn ->
      {:ok,
       [
         %{
           polling_interval: 3600,
           repository_url: "https://github.com/no-tags/f@k3",
           adapter: GithubFake,
           github_token: nil
         }
       ]}
    end)

    start_supervised!(SetupWorker)

    # Wait for children to be created and started
    assert :ok =
             wait_for(fn ->
               %{workers: num} = DynamicSupervisor.count_children(PollerSupervisor)
               num > 0
             end)

    worker_pid = Process.whereis(:f@k3)
    assert worker_pid
    assert %{repo: %{url: "https://github.com/no-tags/f@k3"}} = Poller.state(worker_pid)
  end

  test "start repositories successfully with duplicates" do
    Buildex.Common.Service.MockDatabase
    |> expect(:get_all_repositories, fn ->
      {:ok,
       [
         %{
           polling_interval: 3600,
           repository_url: "https://github.com/no-tags/f@k3",
           adapter: GithubFake,
           github_token: nil
         },
         %{
           polling_interval: 3600,
           repository_url: "https://github.com/no-tags/f@k3",
           adapter: GithubFake,
           github_token: nil
         }
       ]}
    end)

    start_supervised!(SetupWorker)

    # Wait for children to be created and started
    assert :ok =
             wait_for(fn ->
               %{workers: num} = DynamicSupervisor.count_children(PollerSupervisor)
               :timer.sleep(200)
               num == 1
             end)

    worker_pid = Process.whereis(:f@k3)
    assert worker_pid
    assert %{repo: %{url: "https://github.com/no-tags/f@k3"}} = Poller.state(worker_pid)
  end
end
