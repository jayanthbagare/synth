defmodule Sine do
  @sample_rate Config.default_config().sample_rate
  def generate(frequency, duration, amplitude, sample_rate \\ @sample_rate) do
    num_samples = trunc(duration * sample_rate)

    0..num_samples
    |> Enum.map(fn index ->
      t = index / @sample_rate
      :math.sin(2 * :math.pi() * frequency * t)
    end)
  end
end
