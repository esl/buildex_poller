defmodule Buildex.Poller.MixProject do
  use Mix.Project

  def project do
    [
      app: :buildex_poller,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :confex],
      mod: {Buildex.Poller.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:confex, "~> 3.4.0"},
      {:tentacat, "~> 1.1.0"},
      # use master because there aren't newer releases and master has an API function we need
      {:mock, "~> 0.3.2", only: :test},
      {:ex_rabbit_pool, git: "https://github.com/esl/ex_rabbitmq_pool.git", branch: "master"},
      {:buildex_common, git: "https://github.com/esl/buildex_common.git", branch: "master"},
      {:poison, "~> 4.0"},
      {:httpoison, "~> 1.3.0", override: true},
      {:meck, "0.8.13", override: true, only: :test},
      {:mox, "~> 0.4", only: :test}
    ]
  end
end
