defmodule DonutShop.TomlEncoderTest do
  use ExUnit.Case

  # From TOML docs with comments removed
  @toml ~S(
title = "TOML Example"

[owner]
name = "Tom Preston-Werner"
dob = 1979-05-27T07:32:00-08:00

[database]
server = "192.168.1.1"
ports = [ 8001, 8001, 8002 ]
connection_max = 5000
enabled = true

[servers]

  [servers.alpha]
  ip = "10.0.0.1"
  dc = "eqdc10"

  [servers.beta]
  ip = "10.0.0.2"
  dc = "eqdc10"

[clients]
data = [ ["gamma", "delta"], [1, 2] ]

hosts = [
  "alpha",
  "omega"
]
)

  test "encoder" do
    decoded = Toml.decode!(@toml)
    |> IO.inspect()

    
  end
  
end