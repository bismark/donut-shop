import Config

config :donut_shop, DonutShop.Repo,
  database: Path.join(:code.priv_dir(:donut_shop), "database.db")
