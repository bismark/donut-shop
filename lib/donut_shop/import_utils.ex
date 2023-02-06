defmodule DonutShop.ImportUtils do
  alias DonutShop.Utils
  def import_post(path) do
    file = path |> Path.expand() |> File.read!()
    [frontmatter, body] = String.split(file, "}\n\n", parts: 2)
    post = Jason.decode!(frontmatter <> "}")
      |> Utils.map_move("alturls", "alt_urls")
      |> Map.put("text", body)

    post =
      DonutShop.Post.changeset(post)
      |> DonutShop.Repo.insert!()

  end
end
