defmodule Buildex.Poller.SetupSupervisor do
  use Supervisor

  alias Buildex.Poller.{PollerSupervisor, SetupWorker}

  def start_link(args \\ []) do
    name = Keyword.get(args, :name, __MODULE__)
    Supervisor.start_link(__MODULE__, [], name: name)
  end

  def init(_) do
    children = [
      {PollerSupervisor, []},
      {SetupWorker, []}
    ]

    opts = [strategy: :rest_for_one]
    Supervisor.init(children, opts)
  end
end
