defmodule Buildex.Poller.Integration.PollerTest do
  use ExUnit.Case, async: false
  import Mox

  alias AMQP.Basic

  alias Buildex.Poller
  alias Buildex.Poller.Repository.GithubFake
  alias Buildex.Common.Repos.Repo
  alias Buildex.Common.Tags.Tag
  alias Buildex.Common.Jobs.NewReleaseJob
  alias Buildex.Common.Serializers.NewReleaseJobSerializer, as: JobSerializer

  @moduletag :integration
  @queue "test.new_releases.queue"

  # Make sure mocks are verified when the test exits
  setup :set_mox_global
  setup :verify_on_exit!

  setup do
    caller = self()

    rabbitmq_config = [
      channels: 1,
      port: String.to_integer(System.get_env("POLLER_RMQ_PORT") || "5672"),
      queues: [
        [
          queue_name: @queue,
          exchange: "",
          queue_options: [auto_delete: true],
          exchange_options: [auto_delete: true]
        ]
      ],
      caller: caller
    ]

    rabbitmq_conn_pool = [
      :rabbitmq_conn_pool,
      pool_id: :test_pool,
      name: {:local, :test_pool},
      worker_module: ExRabbitPool.Worker.RabbitConnection,
      size: 1,
      max_overflow: 0
    ]

    Application.put_env(:buildex_poller, :rabbitmq_config, rabbitmq_config)
    Application.put_env(:buildex_poller, :database, Buildex.Common.Service.MockDatabase)
    Application.put_env(:buildex_poller, :queue, @queue)
    Application.put_env(:buildex_poller, :exchange, "")

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

    n = :rand.uniform(1_000)
    uniq_name = "test-#{n}"

    {:ok, pool_id: :test_pool, name: uniq_name}
  end

  test "place new job in rabbitmq to be processed later - single tag", %{
    pool_id: pool_id,
    name: name
  } do
    Buildex.Common.Service.MockDatabase
    |> expect(:get_all_tags, fn _url ->
      {:ok, []}
    end)
    |> expect(:create_tag, fn _url, tag -> {:ok, tag} end)

    repo = Repo.new("https://github.com/new-tag/#{name}")
    pid = start_supervised!({Poller, {self(), repo, GithubFake, pool_id}})
    Poller.poll(pid)
    assert_receive {:ok, _tags}, 1000

    ExRabbitPool.with_channel(pool_id, fn {:ok, channel} ->
      {:ok, consumer_tag} = Basic.consume(channel, @queue)
      assert_receive {:basic_deliver, payload, %{consumer_tag: ^consumer_tag}}
      job = JobSerializer.deserialize!(payload)

      assert job ==
               %NewReleaseJob{
                 repo: repo,
                 new_tag: %Tag{
                   commit: %{
                     sha: "2b338092b6da5cd5101072dfdd627cfbb49e4736",
                     url:
                       "https://api.github.com/repos/elixir-lang/elixir/commits/2b338092b6da5cd5101072dfdd627cfbb49e4736"
                   },
                   name: "v1.7.2",
                   node_id: "MDM6UmVmMTIzNDcxNDp2MS43LjI=",
                   tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.7.2",
                   zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.7.2"
                 }
               }
    end)
  end

  test "place multiple jobs in rabbitmq to be processed later - multiple new tags", %{
    pool_id: pool_id,
    name: name
  } do
    Buildex.Common.Service.MockDatabase
    |> expect(:get_all_tags, fn _url ->
      {:ok, []}
    end)
    |> expect(:create_tag, 2, fn _url, tag -> {:ok, tag} end)

    repo = Repo.new("https://github.com/2-new-tags/#{name}")
    pid = start_supervised!({Poller, {self(), repo, GithubFake, pool_id}})
    Poller.poll(pid)
    assert_receive {:ok, _tags}, 1000

    ExRabbitPool.with_channel(pool_id, fn {:ok, channel} ->
      {:ok, consumer_tag} = Basic.consume(channel, @queue)

      assert_receive {:basic_deliver, payload1,
                      %{consumer_tag: ^consumer_tag, delivery_tag: delivery_tag}}

      job1 = JobSerializer.deserialize!(payload1)

      assert job1 ==
               %NewReleaseJob{
                 repo: repo,
                 new_tag: %Tag{
                   commit: %{
                     sha: "2b338092b6da5cd5101072dfdd627cfbb49e4736",
                     url:
                       "https://api.github.com/repos/elixir-lang/elixir/commits/2b338092b6da5cd5101072dfdd627cfbb49e4736"
                   },
                   name: "v1.7.2",
                   node_id: "MDM6UmVmMTIzNDcxNDp2MS43LjI=",
                   tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.7.2",
                   zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.7.2"
                 }
               }

      :ok = Basic.ack(channel, delivery_tag)

      assert_receive {:basic_deliver, payload2,
                      %{consumer_tag: ^consumer_tag, delivery_tag: delivery_tag}}

      :ok = Basic.ack(channel, delivery_tag)

      job2 = JobSerializer.deserialize!(payload2)

      assert job2 ==
               %NewReleaseJob{
                 repo: repo,
                 new_tag: %Tag{
                   commit: %{
                     sha: "8aab53b941ee955f005e7b4e08c333f0b94c48b7",
                     url:
                       "https://api.github.com/repos/elixir-lang/elixir/commits/8aab53b941ee955f005e7b4e08c333f0b94c48b7"
                   },
                   name: "v1.7.1",
                   node_id: "MDM6UmVmMTIzNDcxNDp2MS43LjE=",
                   tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.7.1",
                   zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.7.1"
                 }
               }
    end)
  end

  test "doesn't publish new jobs", %{pool_id: pool_id, name: name} do
    repo = Repo.new("https://github.com/2-new-tags/#{name}")
    pid = start_supervised!({Poller, {self(), repo, GithubFake, pool_id}})

    Buildex.Common.Service.MockDatabase
    |> expect(:get_all_tags, fn _url ->
      GithubFake.get_tags(repo)
    end)

    Poller.poll(pid)

    ExRabbitPool.with_channel(pool_id, fn {:ok, channel} ->
      {:ok, consumer_tag} = Basic.consume(channel, @queue)

      refute_receive {:basic_deliver, _payload, %{consumer_tag: ^consumer_tag}}, 1000
    end)
  end

  test "only publishes new tags jobs", %{pool_id: pool_id, name: name} do
    repo = Repo.new("https://github.com/2-new-tags/#{name}")
    {:ok, [new_tag, tag]} = GithubFake.get_tags(repo)

    Buildex.Common.Service.MockDatabase
    |> expect(:get_all_tags, fn _url ->
      {:ok, [tag]}
    end)
    |> expect(:create_tag, fn _url, ^new_tag -> {:ok, new_tag} end)

    pid = start_supervised!({Poller, {self(), repo, GithubFake, pool_id}})

    Poller.poll(pid)

    assert_receive {:ok, _tags}, 1000

    ExRabbitPool.with_channel(pool_id, fn {:ok, channel} ->
      {:ok, consumer_tag} = Basic.consume(channel, @queue)

      assert_receive {:basic_deliver, payload, %{consumer_tag: ^consumer_tag}}

      job = JobSerializer.deserialize!(payload)

      assert %NewReleaseJob{
               new_tag: %Tag{
                 commit: %{
                   sha: "2b338092b6da5cd5101072dfdd627cfbb49e4736",
                   url:
                     "https://api.github.com/repos/elixir-lang/elixir/commits/2b338092b6da5cd5101072dfdd627cfbb49e4736"
                 },
                 name: "v1.7.2",
                 node_id: "MDM6UmVmMTIzNDcxNDp2MS43LjI=",
                 tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.7.2",
                 zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.7.2"
               }
             } = job
    end)
  end
end
