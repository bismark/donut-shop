import Config

config :phoenix, :json_library, Jason

config :donut_shop, ecto_repos: [DonutShop.Repo]

config :donut_shop, DonutShop.Repo,
  migration_timestamps: [
    type: :utc_datetime,
    inserted_at: :created_at
  ]
