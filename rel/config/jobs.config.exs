use Mix.Config

# Runtime configs

config :repo_jobs, :rabbitmq_config,
  channels: 10,
  queue: System.get_env("QUEUE_NAME"),
  host: System.get_env("RABBIT_HOST"),
  exchange: "",
  queue_options: [durable: true],
  exchange_options: [durable: true]

config :repo_jobs, :consumers, 10
