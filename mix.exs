defmodule DonutShop.MixProject do
  use Mix.Project

  def project do
    [
      app: :donut_shop,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {DonutShop.Application, []}
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:phoenix_live_view, "~> 0.18.3"},
      {:ecto_sqlite3, "~> 0.9.0"},
      {:plug, "~> 1.14"},
      {:bandit, "~> 0.6.4"},
      {:credo, "~> 1.6", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false},
      {:finch, "~> 0.14.0"}
    ]
  end
end
