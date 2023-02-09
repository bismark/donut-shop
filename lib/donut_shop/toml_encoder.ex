defmodule DonutShop.TomlEncoder do

    
  def encode(map, parent_key \\ nil)

  def encode(map, parent_key) when is_map(map)  do
    {tables, root_values} = Enum.split_with(map, fn {_, val} -> is_map(val) end)

    Enum.reduce_while(root_values, {:ok, ""}, fn 
      {key, _}, _ when not is_binary(key) ->  {:halt, {:error, :invalid_key}}
      {key, val}, {:ok, acc} when is_binary(val) ->
        key = maybe_quote_key(key)
        val = escape_string_val(val)
        acc = acc <> "#{key} = #{val}\n"
        {:cont, {:ok, acc}}
      {key, %DateTime{} = dt}, {:ok, acc} ->
        key = maybe_quote_key(key)
        acc = acc <> "#{key} = #{DateTime.to_iso8601(dt)}"
        {:cont, {:ok, acc}}
      {key, float}, {:ok, acc} when is_float(float) ->
        key = maybe_quote_key(key)
        acc = acc <> "#{key} = #{Float.to_string(float)}"
        {:cont, {:ok, acc}}
      {key, int}, {:ok, acc} when is_integer(int) ->
        key = maybe_quote_key(key)
        acc = acc <> "#{key} = #{Integer.to_string(int)}"
        {:cont, {:ok, acc}}
      {key, bool}, {:ok, acc} when is_boolean(bool) ->
        key = maybe_quote_key(key)
        acc = acc <> "#{key} = #{bool}"
        {:cont, {:ok, acc}}

    end)
    |> IO.inspect()

    # Enum.reduce_while(map, {:ok, ""}, fn
    #   {key, _}, _ when not is_binary(key) -> {:halt, {:error, :invalid_key}}
    #   {key, val}, acc when is_map(val) ->
    # end)

  end

  def encode(_not_map, _), do: {:error, :not_a_map}

  defp maybe_quote_key(""), do: ~s/""/
  defp maybe_quote_key(key) do
    cond do
      String.match?(key, ~r/^[A-Za-z0-9_]*$/) -> key
      String.match?(key, ~r/"/) -> "'#{key}'"
      true -> ~s/"#{key}"/
    end
  end

  # TODO cover more cases here...
  defp escape_string_val(val) do
    val =
      val
      |> String.replace(~S|"|, ~S|\"|, global: true)
      |> String.replace(~s|\n|, ~S|\n|, global: true)
    ~s|"#{val}"|
  end

end
