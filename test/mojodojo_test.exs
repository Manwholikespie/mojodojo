defmodule MojodojoTest do
  use ExUnit.Case
  doctest Mojodojo

  test "greets the world" do
    assert Mojodojo.hello() == :world
  end
end
