~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
  default_release: :default,
  default_environment: Mix.env()

environment :prod do
  set(include_erts: false)
  set(include_src: false)
  set(vm_args: "rel/vm.args")
end

release :buildex_poller do
  set(version: current_version(:buildex_poller))

  set(
    applications: [
      :runtime_tools,
      :logger,
      ex_rabbit_pool: :permanent,
      buildex_common: :permanent,
      buildex_poller: :permanent
    ]
  )
end
