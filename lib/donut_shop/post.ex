defmodule DonutShop.Post do
  use DonutShop.Repo.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t,
          date: DateTime.t(),
          alt_urls: [String.t()],
          text: String.t() | nil,
          title: String.t() | nil
        }

  @required [:date]
  @optional [:alt_urls, :title, :text]

  @primary_key {:id, :id, autogenerate: false}
  schema "posts" do
    field :alt_urls, {:array, :string}, default: []
    field :text, :string
    field :title, :string
    field :date, :utc_datetime
  end

  @spec changeset(%__MODULE__{}, map()) :: Ecto.Changeset.t()
  def changeset(struct \\ %__MODULE__{}, params) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> set_id()
  end

  defp set_id(cs) do
    if {:data, nil} == fetch_field(cs, :id) |> IO.inspect() do
      slug_id = cs |> IO.inspect() |> fetch_field!(:date) |> DateTime.to_unix()
      put_change(cs, :id, slug_id)
    else
      cs
    end
    |> IO.inspect()
  end
end
