defmodule SynthTest do
  use ExUnit.Case
  doctest Synth

  test "greets the world" do
    assert Synth.hello() == :world
  end
end
