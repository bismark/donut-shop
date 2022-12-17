defmodule DonutShop.Post do
  use DonutShop.Repo.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          created_at: DateTime.t(),
          updated_at: DateTime.t(),
          alt_urls: [String.t()],
          text: String.t(),
          title: String.t() | nil
        }

  schema "posts" do
    field :alt_urls, {:array, :string}
    field :text, :string
    field :title, :string
    timestamps()
  end

  @spec slug_id(t()) :: String.t()
  def slug_id(post) do
    DateTime.to_unix(post.created_at) |> to_string
  end
end
