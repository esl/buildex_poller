use Mix.Config

config :logger, level: :info

config :buildex_poller, :rabbitmq_conn_pool,
  pool_id: :connection_pool,
  name: {:local, :connection_pool},
  worker_module: ExRabbitPool.Worker.RabbitConnection,
  size: 5,
  max_overflow: 0
