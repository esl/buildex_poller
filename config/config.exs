use Mix.Config

# default System.get_env("GITHUB_AUTH")
config :builex_poller, :github_auth, GITHUB_TOKEN

# Which queue/exchange is BuildexPoller going to use
config :builex_poller,
  queue: [
    name: {:system, QUEUE_NAME, ""}
    # exchange: ""
  ]

# RabbitMQ Connection Config - Setting up rabbimq for us
config :builex_poller, :rabbitmq_config,
  port: 5672,
  channels: 1000,
  # OPTIONAL - Setting up rabbimq queues/exchanges/bindings for us
  queues: [
    queue_name: "",
    exchange: ""
  ]

# RabbitMQ Connection Pool Config

config :builex_poller, :rabbitmq_conn_pool,
  pool_id: POOL_NAME,
  name: {:local, POOL_NAME},
  worker_module: ExRabbitPool.Worker.RabbitConnection,
  size: 2,
  max_overflow: 0

import_config "#{Mix.env()}.exs"
