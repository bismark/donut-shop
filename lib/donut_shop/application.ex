defmodule DonutShop.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DonutShop.Repo,
      {Finch, name: DonutShop.Finch},
      {Bandit, plug: DonutShop.DevServer, scheme: :http, options: [port: 4000]}
    ]

    opts = [strategy: :one_for_one, name: DonutShop.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
