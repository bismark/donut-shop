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

  @spec file_sha256(Path.t()) :: String.t()
  def file_sha256(path) do
    File.stream!(path, [], 2048)
    |> Enum.reduce(:crypto.hash_init(:sha256), fn line, acc -> :crypto.hash_update(acc, line) end)
    |> :crypto.hash_final()
    |> Base.encode16(case: :lower)
  end

  def map_move(map, from, to) do
    with {:ok, val} = Map.fetch(map, from) do
      map
      |> Map.delete(from)
      |> Map.put(to, val)
    end
  end
  
  def map_move!(map, from, to) do
    {val, map} = Map.pop!(map, from)
    Map.put(map, to, val)
  end
end
