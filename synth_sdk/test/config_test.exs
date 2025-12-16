Code.require_file("../lib/synth/config.ex",__DIR__)
defmodule ConfigTest do
  use ExUnit.Case
  # doctest Config

  test "checkmap" do
    maps = Config.default_config()
    assert maps.sample_rate != nil
    assert maps.channels != nil
    assert maps.bit_depth != nil
    assert maps.max_amplitude !=nil
  end
end
