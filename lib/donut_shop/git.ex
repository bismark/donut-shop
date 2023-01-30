defmodule DonutShop.Git do
  defmodule Env do
    for key <- [:git_user_name, :git_user_email] do
      def unquote(key)() do
        Application.fetch_env!(:donut_shop, DonutShop.Git) |> Keyword.fetch!(unquote(key))
      end
    end
  end

  alias __MODULE__.Env

  def clone(from, to) do
    System.cmd("git", ["clone", from, to])
    :ok
  end

  def user_config(repo_path) do
    {_, 0} = System.cmd("git", ["config", "user.name", Env.git_user_name()], cd: repo_path)
    {_, 0} = System.cmd("git", ["config", "user.email", Env.git_user_email()], cd: repo_path)
    :ok
  end

  def add(repo_path, file_path) do
    {_, 0} = System.cmd("git", ["add", file_path], cd: repo_path)
    :ok
  end

  def commit(path, message \\ "commit") do
    {_, 0} = System.cmd("git", ["commit", "-m", message], cd: path)
    :ok
  end

  def push(repo_path) do
    {_, 0} = System.cmd("git", ["push"], cd: repo_path)
    :ok
  end

  def pull(repo_path) do
    {_, 0} = System.cmd("git", ["push"], cd: repo_path)
    :ok
  end

  def lfs_add_file(repo_path, file_path) do
    add(repo_path, file_path)
    commit(repo_path)
    push(repo_path)
    lfs_prune(repo_path)
  end

  def lfs_prune(repo_path) do
    {_, 0} = System.cmd("git", ["lfs", "prune"], cd: repo_path)
    # "Prune" the working directory by reseting to initial commit
    # and then going back to HEAD
    {first_sha, 0} = System.cmd("git", ["rev-list", "--max-parents=0", "HEAD"], cd: repo_path)
    {_, 0} = System.cmd("git", ["checkout", String.trim_trailing(first_sha)], cd: repo_path)
    {_, 0} = System.cmd("git", ["checkout", "main"], cd: repo_path)
  end
end
