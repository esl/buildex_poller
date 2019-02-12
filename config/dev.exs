use Mix.Config

config :buildex_poller,
  queue: "new_releases.queue",
  exchange: ""

config :buildex_poller, :rabbitmq_config,
  channels: 10,
  queues: [
    [
      queue_name: "new_releases.queue",
      exchange: ""
    ]
  ]

config :buildex_poller, :rabbitmq_conn_pool,
  pool_id: :connection_pool,
  name: {:local, :connection_pool},
  worker_module: ExRabbitPool.Worker.RabbitConnection,
  size: 2,
  max_overflow: 0
