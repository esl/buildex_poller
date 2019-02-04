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
    get_rabbitmq_config()
    |> Keyword.fetch!(:queue)
  end

  def get_rabbitmq_exchange() do
    get_rabbitmq_config()
    |> Keyword.fetch!(:exchange)
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

  def get_database_reconnection_interval() do
    Application.get_env(:buildex_poller, :database_reconnect, 5000)
  end
end
