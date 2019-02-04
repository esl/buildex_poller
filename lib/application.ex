defmodule Buildex.Poller.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Buildex.Poller.{SetupSupervisor, Config}

  def start(_type, _args) do
    # List all child processes to be supervised

    Confex.resolve_env!(:buildex_poller)

    rabbitmq_config = Config.get_rabbitmq_config()
    rabbitmq_conn_pool = Config.get_connection_pool_config()

    children = [
      {ExRabbitPool.PoolSupervisor,
       [rabbitmq_config: rabbitmq_config, rabbitmq_conn_pool: rabbitmq_conn_pool]},
      {SetupSupervisor, []}
    ]

    # if for some reason the Supervisor of the RabbitMQ connection pool is terminated we should
    # restart the Pooler workers and DB because we shouldn't store new tags without pushing them into
    # a queue to be processed later, if we allow this, then we may not process some tags when the
    # connection pool isn't available and there are new tags saved into the DB.
    opts = [strategy: :rest_for_one, name: Buildex.Poller.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
