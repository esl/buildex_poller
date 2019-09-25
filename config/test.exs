use Mix.Config

config :logger, level: :warn
# https://github.com/pma/amqp/wiki/Upgrade-from-0.X-to-1.0#lager
config :lager, handlers: [level: :critical]
config :buildex_poller, :database, Buildex.Common.Services.FakeDatabase
config :libcluster, :topologies, []
