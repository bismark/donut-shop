defmodule DonutShop.ContentGitRepo do
  alias DonutShop.{Git, Utils}

  defmodule Env do
    for key <- [:remote, :path] do
      def unquote(key)() do
        Application.fetch_env!(:donut_shop, DonutShop.ContentGitRepo)
        |> Keyword.fetch!(unquote(key))
      end
    end
  end

  def clone() do
    Git.clone(Env.remote(), Env.path())
    Git.user_config(Env.path())
  end

end
