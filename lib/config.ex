defmodule Buildex.Poller.Config do
  def get_github_access_token() do
    Application.get_env(:buildex_poller, :github_auth, System.get_env("GITHUB_AUTH"))
  end

  def get_repos() do
    Application.get_env(:buildex_poller, :repos, [])
  end

  def get_connection_pool_config() do
    Application.get_env(:buildex_poller, :rabbitmq_conn_pool, [])
  end

  def get_connection_pool_id() do
    get_connection_pool_config()
    |> Keyword.fetch!(:pool_id)
  end

  def get_rabbitmq_config() do
    Application.get_env(:buildex_poller, :rabbitmq_config, [])
  end

  def get_rabbitmq_queue() do
    Application.fetch_env!(:buildex_poller, :queue)
  end

  def get_rabbitmq_exchange() do
    Application.fetch_env!(:buildex_poller, :exchange)
  end

  def get_rabbitmq_client() do
    get_rabbitmq_config()
    |> Keyword.get(:adapter, ExRabbitPool.RabbitMQ)
  end

  def get_rabbitmq_reconnection_interval() do
    get_rabbitmq_config()
    |> Keyword.get(:reconnect, 5000)
  end

  def priv_dir() do
    priv_dir = :buildex_poller |> :code.priv_dir() |> to_string()
    Application.get_env(:buildex_poller, :priv_dir, priv_dir)
  end

  def get_database() do
    Application.get_env(:buildex_poller, :database, Buildex.Common.Services.Database)
  end

  def get_database_reconnection_interval() do
    Application.get_env(:buildex_poller, :database_reconnect, 5000)
  end

  def get_cluster_topologies() do
    Application.get_env(:libcluster, :topologies)
  end

  def get_nodes() do
    case Application.get_env(:repo_poller, :poller_nodes) do
      nil ->
        "POLLER_NODES"
        |> System.get_env()
        |> String.split(",")
        |> Enum.map(&String.to_atom/1)

      nodes ->
        nodes
    end
  end
end
