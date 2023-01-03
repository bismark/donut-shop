defmodule DonutShop.Utils do
  @spec from_utc_iso8601(String.t()) :: {:ok, DateTime.t()} | {:error, atom}
  def from_utc_iso8601(dt) do
    case DateTime.from_iso8601(dt) do
      {:ok, dt, 0} -> {:ok, dt}
      {:ok, _dt, _} -> {:error, :not_utc}
      _ -> {:error, :invalid}
    end
  end

  @spec from_utc_iso8601!(String.t()) :: DateTime.t()
  def from_utc_iso8601!(dt) do
    case from_utc_iso8601(dt) do
      {:ok, dt} -> dt
      {:error, err} -> raise err
    end
  end
end
