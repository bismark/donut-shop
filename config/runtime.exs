import Config

config :donut_shop, DonutShop.Repo,
  database: Path.join(:code.priv_dir(:donut_shop), "database.db")

config :donut_shop, DonutShop.Git,
  git_user_name: System.fetch_env!("GIT_USER_NAME"),
  git_user_email: System.fetch_env!("GIT_USER_EMAIL")

config :donut_shop, DonutShop.MediaGitRepo,
  remote: System.fetch_env!("MEDIA_REPO_REMOTE"),
  path: System.fetch_env!("MEDIA_REPO_PATH"),
  lfs_endpoint: System.fetch_env!("MEDIA_REPO_LFS_ENDPOINT"),
  lfs_username: System.fetch_env!("MEDIA_REPO_LFS_USERNAME"),
  lfs_password: System.fetch_env!("MEDIA_REPO_LFS_PASSWORD")
