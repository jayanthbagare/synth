Code.require_file("../../lib/synth/waveform/sine.ex", __DIR__)

defmodule ConfigTest do
  use ExUnit.Case

  test "test_sine" do
    sine_vals = Sine.generate(440, 1.0, 1.0)
    assert sine_vals != nil
  end
end
