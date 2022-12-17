defmodule DonutShopTest do
  use ExUnit.Case
  doctest DonutShop

  test "greets the world" do
    assert DonutShop.hello() == :world
  end
end
