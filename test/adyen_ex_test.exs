defmodule AdyenExTest do
  use ExUnit.Case
  doctest AdyenEx

  test "greets the world" do
    assert AdyenEx.hello() == :world
  end
end
