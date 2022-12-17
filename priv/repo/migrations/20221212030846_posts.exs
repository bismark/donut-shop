defmodule DonutShop.Repo.Migrations.Posts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :alt_urls, {:array, :string}, default: []
      add :text, :text, null: false
      add :title, :text
      timestamps()
    end
  end
end
