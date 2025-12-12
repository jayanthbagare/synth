# Elixir Synth – A Pure-Elixir Software Synthesizer

A modular, functional software synthesizer written entirely in Elixir.  
No external dependencies except the Erlang/OTP runtime. Generates 16-bit mono WAV files from code using oscillators, envelopes, filters, LFOs, a sequencer, additive waveforms, drums, and a growing modulation system.

Perfect for learning synthesis, algorithmic composition, or just having fun making bleeps and bloops with Elixir.

## Features

- Pure additive & band-limited waveforms (sine, square, saw, triangle)
- Classic ADSR envelope
- Tremolo LFO (easily extensible to vibrato, filter modulation, etc.)
- Simple one-pole low-pass filter (IIR)
- Pitch-slide generator (perfect for kick drums and laser sounds)
- White-noise generator
- Music-theory helpers (note → frequency, rests, octaves)
- Polyphonic sequencer with per-note duration
- Drum utilities (kick prototype included)
- 16-bit mono WAV export
- 100% functional, immutable signal flow – idiomatic Elixir
- Fully modular – every component lives in its own file and can be enhanced independently

## Project Structure

```
lib/synth/
├── config.ex                  # Sample rate & global defaults
├── oscillator.ex              # Main waveform entry point
├── waveform/
│   ├── sine.ex
│   ├── square.ex
│   ├── saw.ex
│   └── triangle.ex
├── envelope/
│   └── adsr.ex
├── lfo/
│   └── tremolo.ex
├── filter/
│   └── low_pass.ex
├── effects/                   # (future: delay, reverb, distortion…)
├── mixer.ex
├── sequencer.ex
├── note.ex                    # Note → frequency conversion
├── drum/
│   ├── kick.ex
│   └── noise.ex
├── wav_writer.ex
└── synth.ex                   # Public façade & example instrument patches

```

## Quick Start
```
# Run in iex -S mix
iex> alias Synth.{Oscillator, Envelope.ADSR, WavWriter}

# A single A4 note with envelope
Oscillator.sine(440, 2.0)
|> ADSR.apply(%{attack: 0.01, decay: 0.2, sustain: 0.7, release: 0.5})
|> WavWriter.save("a440.wav")
```
## Play a Melody
```
melody = [
  %{note: :C,  octave: 4, duration: 0.5},
  %{note: :E,  octave: 4, duration: 0.5},
  %{note: :G,  octave: 4, duration: 0.5},
  %{note: :C,  octave: 5, duration: 1.0},
  %{note: :rest, duration: 0.5},
  %{note: :B,  octave: 4, duration: 1.5}
]

Synth.sequence(melody, &Oscillator.saw/2)
|> Synth.WavWriter.save("c-major-arpeggio.wav")

```

## Create Your Own Instrument Patch

```
my_lead = fn freq, dur ->
  Oscillator.saw(freq, dur)
  |> Synth.LFO.Tremolo.apply(rate: 5.5, depth: 0.4)
  |> Synth.Filter.LowPass.apply(cutoff_hz: 1800)
  |> Synth.Envelope.ADSR.apply(%{
       attack: 0.02, decay: 0.15, sustain: 0.6, release: 0.4
     })
end

Synth.sequence(your_melody, my_lead)
|> Synth.WavWriter.save("fat-saw-lead.wav")

```

## Kick Drum Example
```

kick = Synth.Drum.Kick.generate(duration: 0.5)
       |> Synth.Envelope.ADSR.apply(%{attack: 0.001, decay: 0.3, sustain: 0, release: 0.0})

Synth.WavWriter.save(kick, "kick.wav")

```

## Installation & Running
```

git clone <https://github.com/yourusername/elixir-synth.git>
cd elixir-synth
mix compile

# Interactive session (best for sound design)

iex -S mix

```

All functions return plain lists of floats [-1.0 … 1.0].
Pipe the result into Synth.WavWriter.save/2 to get a playable WAV file.


## Roadmap / Ideas to Implement
* [ ] Proper band-limited oscillators (BLIT, minBLEP, polyBLEP)
* [ ] Moog ladder filter / State-Variable Filter with resonance
* [ ] Real modulation matrix (LFO → cutoff, envelope → pitch, etc.)
* [ ] Delay + reverb effects
* [ ] Wavetable oscillator
* [ ] FM synthesis module
* [ ] Polyphony & voice stealing
* [ ] MIDI file import
* [ ] Live playback via PortAudio NIF (optional)

## Why Elixir?
* Immutable data → perfect for pure signal chains
* Pattern matching & pipelines make patching feel natural
* Concurrency makes polyphony trivial later
* Hot code reloading in iex = instant sound design feedback
* No C dependencies = works everywhere Erlang/BEAM runs

## Contributing
Pull requests are very welcome!
Especially:

* Better filters
* More effects
* Cleaner math / performance improvements
* Tests (we need them!)
* Documentation & examples

License
MIT © Jayanth Bagare

