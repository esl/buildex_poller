# buildex_poller

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `builex_poller` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:buildex_poller, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/builex_poller](https://hexdocs.pm/builex_poller).

- BuildexPoller polls GitHub repos for new tags
- if there are new tags it publishes a message to RabbitMQ using the connection/channels pool

## General Overview

- ExRabbitPool creates a pool of connections to RabbitMQ
- each connection worker traps exits and links the connection process to it
- each connection worker creates a pool of channels and links them to it
- when a client checks out a channel out of the pool the connection worker monitors that client to return the channel into it in case of a crash
- BuildexPoller polls GitHub repos for new tags
- if there are new tags it publishes a message to RabbitMQ using the connection/channels pool

![screen shot 2018-08-17 at 7 51 36 am](https://user-images.githubusercontent.com/1157892/44267068-71e83100-a1f2-11e8-8d73-2bc7a1914733.png)

## Configuration

```ex
# default System.get_env("GITHUB_AUTH")
config :builex_poller, :github_auth, GITHUB_TOKEN

# Which queue/exchange is BuildexPoller going to use
config :builex_poller,
  queue: QUEUE_NAME,
  exchange: ""

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
  worker_module: BugsBunny.Worker.RabbitConnection,
  size: 2,
  max_overflow: 0
```
