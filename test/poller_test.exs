defmodule Buildex.PollerTest do
  use ExUnit.Case, async: false
  import Mox

  import ExUnit.CaptureLog

  alias Buildex.Poller
  alias Buildex.Poller.Repository.GithubFake
  alias Buildex.Common.Repos.Repo
  alias Buildex.Common.Tags.Tag

  alias ExRabbitPool.FakeRabbitMQ
  alias ExRabbitPool.Worker.RabbitConnection

  # Make sure mocks are verified when the test exits
  setup :set_mox_global
  setup :verify_on_exit!

  setup do
    n = :rand.uniform(100)
    pool_id = String.to_atom("test_pool#{n}")
    caller = self()

    rabbitmq_config = [
      channels: 1,
      port: String.to_integer(System.get_env("POLLER_RMQ_PORT") || "5672"),
      queue: "new_releases.queue",
      exchange: "",
      adapter: FakeRabbitMQ,
      caller: caller,
      reconnect: 10,
      queue_options: [auto_delete: true],
      exchange_options: [auto_delete: true]
    ]

    rabbitmq_conn_pool = [
      :rabbitmq_conn_pool,
      pool_id: pool_id,
      name: {:local, pool_id},
      worker_module: RabbitConnection,
      size: 1,
      max_overflow: 0
    ]

    Application.put_env(:buildex_poller, :rabbitmq_config, rabbitmq_config)
    Application.put_env(:buildex_poller, :database, Buildex.Common.Service.MockDatabase)

    start_supervised!(%{
      id: ExRabbitPool.PoolSupervisorTest,
      start:
        {ExRabbitPool.PoolSupervisor, :start_link,
         [
           [rabbitmq_config: rabbitmq_config, rabbitmq_conn_pool: rabbitmq_conn_pool],
           ExRabbitPool.PoolSupervisorTest
         ]},
      type: :supervisor
    })

    {:ok, pool_id: pool_id}
  end

  test "gets tags and re-schedule poll", %{pool_id: pool_id} do
    Buildex.Common.Service.MockDatabase
    |> expect(:get_all_tags, 2, fn _url ->
      {:ok, []}
    end)
    |> expect(:create_tag, 2, fn _url, tag ->
      {:ok, tag}
    end)

    repo = Repo.new("https://github.com/new-tag/elixir", 50)
    pid = start_supervised!({Poller, {self(), repo, GithubFake, pool_id}})
    Poller.poll(pid)
    assert_receive {:ok, tags}, 1000
    assert_receive {:ok, ^tags}
  end

  test "gets repo tags and store them", %{pool_id: pool_id} do
    repo = Repo.new("https://github.com/elixir-lang/elixir")

    Buildex.Common.Service.MockDatabase
    |> expect(:get_all_tags, fn _url ->
      {:ok, []}
    end)
    |> expect(:create_tag, 21, fn _url, tag ->
      {:ok, tag}
    end)

    pid = start_supervised!({Poller, {self(), repo, GithubFake, pool_id}})
    Poller.poll(pid)
    assert_receive {:ok, _tags}, 1000
  end

  test "gets repo tags and update them", %{pool_id: pool_id} do
    tags = Poison.decode!(File.read!("test/poller_test.json"), as: [%Tag{name: nil}])

    Buildex.Common.Service.MockDatabase
    |> expect(:get_all_tags, fn _url ->
      {:ok, tags}
    end)
    |> expect(:create_tag, 12, fn _url, tag ->
      {:ok, tag}
    end)

    repo = Repo.new("https://github.com/elixir-lang/elixir")
    pid = start_supervised!({Poller, {self(), repo, GithubFake, pool_id}})
    Poller.poll(pid)
    assert_receive {:ok, _tags}, 1000
  end

  test "handles rate limit errors", %{pool_id: pool_id} do
    repo = Repo.new("https://github.com/rate-limit/fake")

    assert capture_log(fn ->
             pid = start_supervised!({Poller, {self(), repo, GithubFake, pool_id}})
             Poller.poll(pid)
             assert_receive {:error, :rate_limit, retry}
             assert retry > 0
           end) =~ "rate limit reached for repo: rate-limit/fake retrying in 50 ms"
  end

  test "re-schedule poll after rate limit errors", %{pool_id: pool_id} do
    repo = Repo.new("https://github.com/rate-limit/fake", 50)

    assert capture_log(fn ->
             pid = start_supervised!({Poller, {self(), repo, GithubFake, pool_id}})
             Poller.poll(pid)
             assert_receive {:error, :rate_limit, retry}
             assert_receive {:error, :rate_limit, ^retry}
           end) =~ "rate limit reached for repo: rate-limit/fake retrying in 50 ms"
  end

  test "handles errors when polling fails due to a custom error", %{pool_id: pool_id} do
    repo = Repo.new("https://github.com/404/fake")

    assert capture_log(fn ->
             pid = start_supervised!({Poller, {self(), repo, GithubFake, pool_id}})
             Poller.poll(pid)
             assert_receive {:error, :not_found}
           end) =~ "error polling info for repo: 404/fake reason: :not_found"
  end

  test "handles errors when trying to get a channel", %{pool_id: pool_id} do
    Buildex.Common.Service.MockDatabase
    |> expect(:get_all_tags, fn _url ->
      {:ok, []}
    end)

    repo = Repo.new("https://github.com/elixir-lang/elixir")
    pid = start_supervised!({Poller, {self(), repo, GithubFake, pool_id}})

    ExRabbitPool.with_channel(pool_id, fn {:ok, _channel} ->
      log =
        capture_log(fn ->
          Poller.poll(pid)
          assert_receive {:error, :out_of_retries}
          :timer.sleep(100)
          refute Process.alive?(pid)
        end)

      assert log =~ "error getting a channel reason: :out_of_channels"
    end)
  end

  test "handles errors when publishing a job fails", %{pool_id: pool_id} do
    Buildex.Common.Service.MockDatabase
    |> expect(:get_all_tags, fn _url ->
      {:ok, []}
    end)

    repo = Repo.new("https://github.com/error/fake")

    assert capture_log(fn ->
             pid = start_supervised!({Poller, {self(), repo, GithubFake, pool_id}})
             Poller.poll(pid)
             assert_receive {:job_not_published, _}
             refute_receive {:job_published, _}
           end) =~
             "error publishing new release v1.7.2 for https://github.com/error/fake reason: :kaboom"
  end
end
