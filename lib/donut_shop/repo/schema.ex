defmodule DonutShop.Repo.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      alias Ecto.Association.NotLoaded

      @timestamps_opts [
        inserted_at: :created_at,
        inserted_at_source: :created_at,
        type: :utc_datetime
      ]
    end
  end
end
