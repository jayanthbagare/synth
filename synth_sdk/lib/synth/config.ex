defmodule Config do
  def default_config() do
    %{sample_rate: 44100, bit_depth: 16, channels: 1, max_amplitude: 1.0}
  end
end
