defmodule Buildex.Poller.PollerSupervisorTest do
  use ExUnit.Case, async: false
  import Mox
  alias Buildex.Poller
  alias Buildex.Poller.PollerSupervisor, as: PS
  alias Buildex.Poller.Config
  alias Buildex.Common.Tasks.Runners.DockerBuild
  alias Buildex.Poller.Repository.GithubFake
  alias Buildex.Common.Repos.Repo
  alias Buildex.Common.Tasks.Task

  @tag capture_log: true
  test "setups a supervision tree with repo" do
    task = Task.new(runner: DockerBuild, build_file_content: "This is a test file\n")

    repo =
      "https://github.com/404/elixir"
      |> Repo.new(3_600_000, GithubFake)
      |> Repo.set_tasks([task])

    Buildex.Poller.MockConfig
    |> expect(:get_connection_pool_id, 0, fn ->
      :random_id
    end)

    start_supervised!({PS, name: :PollerSupervisorTest})
    assert {:ok, child_pid} = PS.start_child(repo)

    assert %{
             repo: %{
               url: "https://github.com/404/elixir",
               owner: "404",
               name: "elixir",
               tasks: [task]
             }
           } = Poller.state(child_pid)

    assert %{build_file_content: "This is a test file\n", runner: DockerBuild} = task
  end

  # @tag capture_log: true
  # test "setups a supervision tree with map" do
  #   repo = %{
  #     repository_url: "https://github.com/404/erlang",
  #     polling_interval: 3600,
  #     adapter: GithubFake,
  #     github_token: nil
  #   }

  #   get_connection_pool_id_fn = fn -> :random_id end

  #   with_mocks [
  #     {Config, [], [get_connection_pool_id: get_connection_pool_id_fn]}
  #   ] do
  #     start_supervised!({PS, name: :PollerSupervisorTest})
  #     assert {:ok, child_pid} = PS.start_child(repo)

  #     assert %{
  #              repo: %{
  #                url: "https://github.com/404/erlang",
  #                owner: "404",
  #                name: "erlang",
  #                tasks: []
  #              }
  #            } = Poller.state(child_pid)
  #   end
  # end
end
