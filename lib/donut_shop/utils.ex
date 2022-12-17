defmodule DonutShop.Utils do
  def from_utc_iso8601(dt) do
    case DateTime.from_iso8601(dt) do
      {:ok, dt, 0} -> {:ok, dt}
      {:ok, _dt, _} -> {:error, :not_utc}
      err -> err
    end
  end

  def from_utc_iso8601!(dt) do
    case from_utc_iso8601(dt) do
      {:ok, dt} -> dt
      err -> raise ArgumentError, err
    end
  end
end
