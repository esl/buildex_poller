# buildex_poller


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `repo_poller` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:buildex_poller, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/repo_poller](https://hexdocs.pm/repo_poller).



- RepoPoller polls GitHub repos for new tags
- if there are new tags it publishes a message to RabbitMQ using the connection/channels pool



![screen shot 2018-08-17 at 7 51 36 am](https://user-images.githubusercontent.com/1157892/44267068-71e83100-a1f2-11e8-8d73-2bc7a1914733.png)

