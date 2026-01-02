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

## Roadmap / Ideas to Implement

- [ ] Proper band-limited oscillators (BLIT, minBLEP, polyBLEP)
- [ ] Moog ladder filter / State-Variable Filter with resonance
- [ ] Real modulation matrix (LFO → cutoff, envelope → pitch, etc.)
- [ ] Delay + reverb effects
- [ ] Wavetable oscillator
- [ ] FM synthesis module
- [ ] Polyphony & voice stealing
- [ ] MIDI file import
- [ ] Live playback via PortAudio NIF (optional)

## Contributing

Pull requests are very welcome!
Especially:

- Better filters
- More effects
- Cleaner math / performance improvements
- Tests (we need them!)
- Documentation & examples

License
MIT © Jayanth Bagare
