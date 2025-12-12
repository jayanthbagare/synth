### Elixir Synth – A Pure-Elixir Software Synthesizer
A modular, functional software synthesizer written entirely in Elixir.
No external dependencies except the Erlang/OTP runtime. Generates WAV files from code using oscillators, envelopes, filters, LFOs, a sequencer, additive waveforms, drums, and a simple modulation system.
Perfect for learning synthesis, algorithmic composition, or just having fun making bleeps and bloops with Elixir.

https://github.com/jayanthbagare/synth

Features

Pure additive & band-limited waveforms (sine, square, saw, triangle)
Classic ADSR envelope
Tremolo LFO (easily extensible to vibrato, filter modulation, etc.)
Simple one-pole low-pass filter
Pitch-slide generator (great for kicks and laser sounds)
White-noise generator
Music-theory helpers (note → frequency, rests, octaves)
Polyphonic sequencer with per-note duration
Drum utilities (kick drum prototype included)
16-bit mono WAV export
100% functional, immutable signal flow – perfect Elixir style
Fully modular – every component lives in its own file and can be enhanced independently
