defmodule Buildex.Poller.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Buildex.Poller.{SetupWorker, Config, ClusterConnector}

  def start(_type, _args) do
    # List all child processes to be supervised
    rabbitmq_config = Config.get_rabbitmq_config()
    pool_config = Config.get_connection_pool_config()

    rabbitmq_conn_pool =
      if pool_config == [] do
        []
      else
        [pool_config]
      end

    pool_id =
      case pool_config[:name] do
        nil -> nil
        {_, pool_id} -> pool_id
      end

    children = [
      {Cluster.Supervisor, [Config.get_cluster_topologies()]},
      {ExRabbitPool.PoolSupervisor,
       [rabbitmq_config: rabbitmq_config, connection_pools: rabbitmq_conn_pool]},
      {ExRabbitPool.Worker.SetupQueue, {pool_id, rabbitmq_config}},
      {Horde.Registry, [name: Buildex.DistributedRegistry, keys: :unique]},
      {Horde.DynamicSupervisor, [name: Buildex.DistributedSupervisor, strategy: :one_for_one]},
      {ClusterConnector, []},
      {SetupWorker, []}
    ]

    # if for some reason the Supervisor of the RabbitMQ connection pool is terminated we should
    # restart the Pooler workers and DB because we shouldn't store new tags without pushing them into
    # a queue to be processed later, if we allow this, then we may not process some tags when the
    # connection pool isn't available and there are new tags saved into the DB.
    opts = [strategy: :rest_for_one, name: Buildex.Poller.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
