defmodule AdyenClientTest do
  use ExUnit.Case
  doctest AdyenClient

  test "greets the world" do
    assert AdyenClient.hello() == :world
  end
end
