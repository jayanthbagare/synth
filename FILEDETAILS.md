
## File Details

### lib/synth/config.ex

<b>Purpose:</b> 

This module serves as a central configuration hub for the Synth SDK, providing default values and utility functions to manage parameters like sample rates, amplitudes, and durations. It fits into the SDK by allowing higher-level modules (e.g., instrument or sequencer) to define and pass configs as maps, ensuring modularity without global state. It enables easy customization of audio generation parameters across the library.

<b>Key Functions:</b>

default_config/0: 

	- Inputs: none. 
	- Outputs: a map with default values (e.g., %{sample_rate: 44100, amplitude: 1.0}). High-level behavior: Returns a base config map that can be merged or overridden.

merge_configs/2: 

	- Inputs: two config maps. 
	- Outputs: a merged map prioritizing the second. High-level behavior: Combines configs for parametric overrides.

validate_config/1: 

	- Inputs: a config map. 
	- Outputs: :ok or {:error, reason}. High-level behavior: Checks for valid types and ranges in params.

<b>Algorithm:</b>

For default_config/0: 

	Step 1: Define a static map with standard audio defaults (sample_rate=44100 Hz, bit_depth=16, channels=1, max_amplitude=1.0). 
	Step 2: Return the map immutable.
For merge_configs/2: 

	Step 1: Use pattern matching to extract keys from both maps. 
	Step 2: Recursively merge, preferring values from the second map. 
	Step 3: Return new map.
For validate_config/1: 

	Step 1: Iterate over map keys. 
	Step 2: For each, check type (e.g., sample_rate integer > 0) and range (e.g., amplitude <=1.0). 
	Step 3: Accumulate errors; return :ok if empty.

<b>Configurability:</b> 

All functions operate on passed-in maps, with no internal hardcoding beyond defaults in default_config/0. Higher-level callers pass customized maps, ensuring params like sample_rate are always explicit when forwarded to lower modules.

<b>Extensions:</b> 

Design config maps to be extensible with arbitrary keys (e.g., for future effects like reverb_depth). Add functions for serializing/deserializing configs to JSON for preset storage.

### lib/synth/oscillator.ex

<b>Purpose:</b> 

This module acts as the core waveform generator, orchestrating different waveform types (sine, square, etc.) to produce audio samples. It integrates with envelopes, LFOs, and filters by taking their outputs as params, enabling modular synthesis of tones.

<b>Key Functions:</b>

generate/5: 

	- Inputs: waveform_type (atom, e.g., :sine), frequency (float Hz), duration (float seconds), sample_rate (integer Hz), amplitude (float 0-1). 
	- Outputs: list of float samples (-1 to 1). High-level behavior: Produces raw oscillator samples based on type.
modulate/3: 

	- Inputs: samples (list), modulator_samples (list from LFO), depth (float 0-1). 
	- Outputs: modulated samples list. High-level behavior: Applies frequency or amplitude modulation.

<b>Algorithm:</b>

For generate/5: 

	Step 1: Calculate total samples = duration *sample_rate. 
	Step 2: Dispatch to specific waveform module based on type (e.g., Sine.generate/4). 
	Step 3: For each time step t = index / sample_rate, compute phase = 2* π *frequency* t. 
	Step 4: Apply waveform formula (delegated), scale by amplitude, collect in list.
For modulate/3: 

	Step 1: Ensure lists same length; pad/truncate if needed. 
	Step 2: For each sample pair (osc, mod), new_sample = osc *(1 + depth* mod) for AM, or adjust phase cumulatively for FM: phase_offset += mod * depth, then recompute waveform. 
	Step 3: Normalize to -1..1 range.

<b>Configurability:</b> 

Every param (frequency, sample_rate, etc.) is passed explicitly; no defaults here—callers (e.g., from instrument) supply via config maps. Waveform_type allows switching without module changes.

<b>Extensions:</b> 

Add support for custom waveform functions as callbacks. Include phase_offset arg for polyphonic syncing. Prepare for pulse-width modulation in square/saw by adding optional params.

### lib/synth/waveform/sine.ex

<b>Purpose:</b> 

Provides pure sine wave generation, a fundamental building block for oscillators. It fits by being called from oscillator.ex to compute smooth, harmonic tones used in subtractive synthesis.

<b>Key Functions:</b>

generate/4: 

	- Inputs: frequency (float Hz), duration (float seconds), sample_rate (integer Hz), amplitude (float 0-1). 
	- Outputs: list of float samples. High-level behavior: Creates sinusoidal waveform samples.

<b>Algorithm:</b>

For generate/4: 

	Step 1: Compute num_samples = round(duration *sample_rate). 
	Step 2: Initialize empty list. 
	Step 3: For index in 0..num_samples-1, t = index / sample_rate. 
	Step 4: sample = amplitude* sin(2 *π* frequency * t). 
	Step 5: Append to list (use Enum.map for immutability). 
	Step 6: Return list.

<b>Configurability:</b> 

All aspects (freq, duration, etc.) passed as args; no internal constants. Amplitude scales output dynamically.

<b>Extensions:</b> 

Add phase arg for offset. Support harmonics by allowing multiplier lists for additive synthesis.

### lib/synth/waveform/square.ex

<b>Purpose:</b> 

Generates square waves for bright, buzzy tones. Integrated via oscillator.ex for use in instruments needing harsh timbres.

<b>Key Functions:</b>

generate/5: 

	- Inputs: frequency (float Hz), duration (float seconds), sample_rate (integer Hz), amplitude (float 0-1), duty_cycle (float 0-1, default 0.5 via caller). 
	- Outputs: list of float samples. High-level behavior: Produces binary high/low waves.

<b>Algorithm:</b>

For generate/5: 

	Step 1: num_samples = round(duration * sample_rate). 
	Step 2: period = sample_rate / frequency. 
	Step 3: For each index, phase = fmod(index / period, 1.0). 
	Step 4: If phase < duty_cycle, sample = amplitude; else sample = -amplitude. 
	Step 5: Collect via Stream.map for efficiency.

<b>Configurability:</b> 

Duty_cycle passed for PWM; all else parametric.

<b>Extensions:</b> 

Anti-aliasing via band-limiting (future param for oversampling).


### lib/synth/waveform/saw.ex

<b>Purpose:</b> 

Creates sawtooth waves for rich, string-like sounds. Called by oscillator for subtractive synth bases.

<b>Key Functions:</b>

generate/4: 

	- Inputs: frequency (float Hz), duration (float seconds), sample_rate (integer Hz), amplitude (float 0-1). 
	- Outputs: list of float samples. High-level behavior: Linear ramp up/down.

<b>Algorithm:</b>

For generate/4: 

	Step 1: num_samples = round(duration *sample_rate). 
	Step 2: period = sample_rate / frequency. 
	Step 3: For index, phase = fmod(index / period, 1.0). 
	Step 4: sample = amplitude* (2 * phase - 1). 
	Step 5: Map and return list.

<b>Configurability:</b> 

Fully arg-based; amplitude scales.

<b>Extensions:</b> 

Reverse saw via direction param.


### lib/synth/waveform/triangle.ex

<b>Purpose:</b> 

Produces triangle waves for mellow tones. Supports oscillator in creating flute-like instruments.

<b>Key Functions:</b>

generate/4: 

	- Inputs: frequency (float Hz), duration (float seconds), sample_rate (integer Hz), amplitude (float 0-1). 
	- Outputs: list of float samples. High-level behavior: Symmetric rise/fall.

<b>Algorithm:</b>

For generate/4: 

	Step 1: num_samples = round(duration *sample_rate). 
	Step 2: period = sample_rate / frequency. 
	Step 3: For index, phase = fmod(index / period, 1.0). 
	Step 4: If phase < 0.5, sample = amplitude* (4 *phase - 1); else sample = amplitude* (3 - 4 * phase). 
	Step 5: Collect list.

<b>Configurability:</b> 

All params passed; no hardcoded shapes.

<b>Extensions:</b> 

Asymmetry via peak_position arg.


### lib/synth/envelope/adsr.ex

<b>Purpose:</b> 

Implements ADSR envelope for shaping amplitude over time. Applied post-oscillator to add dynamics, integrating with instruments for note lifecycles.

<b>Key Functions:</b>

generate/6: 

	- Inputs: attack (float sec), decay (float sec), sustain (float 0-1 level), release (float sec), duration (float sec), sample_rate (integer). 
	- Outputs: list of envelope values (0-1). High-level behavior: Creates amplitude curve.
apply/2: 

	- Inputs: samples (list), envelope (list). 
	- Outputs: enveloped samples. High-level behavior: Multiplies pointwise.

<b>Algorithm:</b>

For generate/6: 

	Step 1: Compute segment samples: att_s = attack *sample_rate, etc.; total = duration* sample_rate. 
	Step 2: Attack: linear ramp 0 to 1 over att_s. 
	Step 3: Decay: exp/linear from 1 to sustain over dec_s. 
	Step 4: Sustain: constant at sustain until release start. 
	Step 5: Release: linear/exp to 0 over rel_s. 
	Step 6: Pad if needed.
For apply/2: 

	Step 1: Zip lists. 
	Step 2: For each (samp, env), new = samp * env. 
	Step 3: Return new list.

<b>Configurability:</b> 

All times/levels passed; curves (linear/exp) via optional arg.

<b>Extensions:</b> 

Multi-stage envelopes; curve shapes as functions.


### lib/synth/lfo.ex

<b>Purpose:</b> 

Generates low-frequency oscillators for modulation (vibrato, tremolo). Modulates oscillator or filter params dynamically.

<b>Key Functions:</b>

generate/5: 

	- Inputs: frequency (float Hz <20), waveform (:sine etc.), depth (float), duration (float sec), sample_rate (integer). 
	- Outputs: list of mod values (-1 to 1). High-level behavior: Slow waveform for modulation.

apply_to_param/3: 

	- Inputs: base_param (float), lfo_samples (list), rate (float). 
	- Outputs: list of modulated params.

<b>Algorithm:</b>

For generate/5: 

	Similar to oscillator: delegate to waveform, scale by depth.
For apply_to_param/3: 

	Step 1: For each lfo_val, mod_param = base_param *(1 + rate* lfo_val). 
	Step 2: Return list.

<b>Configurability:</b> 

Waveform/freq/depth all args.

<b>Extensions:</b> 

Bipolar/unipolar modes; sync to tempo.


### lib/synth/filter/low_pass.ex

<b>Purpose:</b> 

Applies low-pass filtering to attenuate high frequencies. Post-processes oscillator output for warmer sounds.

<b>Key Functions:</b>

apply/4: 

	- Inputs: samples (list), cutoff (float Hz), q (float resonance), sample_rate (integer). 
	- Outputs: filtered samples. High-level behavior: Smooths signal.

<b>Algorithm:</b>

For apply/4: Use biquad filter.

	Step 1: Compute coeffs: omega = 2πcutoff/sample_rate, alpha = sin(omega)/(2q). 
	Step 2: a0=1+alpha, etc. for IIR. 
	Step 3: Initialize state vars. 
	Step 4: For each sample, y = (b0x + b1x1 + b2x2 - a1y1 - a2y2)/a0; update states. 
	Step 5: Collect y's.


<b>Configurability:</b> 

Cutoff/q passed; no fixed values.

<b>Extensions:</b> 

Add high-pass/band; modulation input.


### lib/synth/instrument.ex

<b>Purpose:</b> 

Combines oscillators, envelopes, LFOs, filters into playable instruments. Higher-level abstraction for sound design.

<b>Key Functions:</b>

synthesize_note/3: 

	- Inputs: note_config (map: freq, duration, etc.), synth_config (map: osc_type, adsr_params), sample_rate (int). 
	- Outputs: samples list. High-level behavior: Builds full note audio.

polyphonic_mix/2: 

	- Inputs: notes_list (list of samples), gain (float). 
	- Outputs: mixed samples.

<b>Algorithm:</b>

For synthesize_note/3: 

	Step 1: Extract params from maps. 
	Step 2: Gen osc samples. 
	Step 3: Apply LFO if present. 
	Step 4: Apply envelope. 
	Step 5: Filter. Step 6: Normalize.

For polyphonic_mix/2: 

	Step 1: Pad to longest. 
	Step 2: Sum pointwise, divide by sqrt(num_voices) * gain.

<b>Configurability:</b> 

All via maps; defaults from config.ex.

<b>Extensions:</b> 

Effects chain as list of functions.


### lib/synth/presets.ex

<b>Purpose:</b> 

Stores and retrieves instrument presets as config maps. Facilitates quick sound selection.

<b>Key Functions:</b>

get_preset/1: 

	- Inputs: preset_name (atom). 
	- Outputs: config map. High-level behavior: Returns predefined params.

list_presets/0: 
    - Outputs: list of atoms.

<b>Algorithm:</b>

For get_preset/1: 

	Step 1: Pattern match name to return map (e.g., :bass => %{osc: :saw, adsr: {...}}).

For list_presets/0: 

	Step 1: Return static list.

<b>Configurability:</b> 

Presets are maps; callers override.

<b>Extensions:</b> 

Load from files; user-defined.


### lib/synth/sequencer.ex

<b>Purpose:</b>

Sequences notes or events over time. Orchestrates instrument calls for patterns.

<b>Key Functions:</b>

sequence/3: 

	- Inputs: events (list of maps: {time, note_config}), total_duration (float), sample_rate (int). 
	- Outputs: mixed samples. High-level behavior: Places notes in timeline.

render_pattern/2: 

	- Inputs: pattern (list of note_configs), tempo (float BPM). 
	- Outputs: samples.

<b>Algorithm:</b>

For sequence/3: 

	Step 1: Sort events by time. 
	Step 2: Init buffer of zeros (total * sr). 
	Step 3: For each event, gen note samples, offset insert into buffer. 
	Step 4: Mix overlaps by summing.

For render_pattern/2: 

	Step 1: Compute beat_dur = 60/tempo. 
	Step 2: Cumulatively place notes.

<b>Configurability:</b> 

Events/tempo passed.

<b>Extensions:</b> 

Looping; MIDI import.


### lib/synth/note.ex

<b>Purpose:</b> 

Handles note-to-frequency conversion and basic note structs. Supports sequencer/instrument.

<b>Key Functions:</b>

freq_from_note/2: 

	- Inputs: note (atom/string, e.g., :A4), tuning (float base=440). 
	- Outputs: freq float. High-level behavior: MIDI/semitione calc.

create_note/4: 

	- Inputs: pitch (atom), duration (float), velocity (float 0-1), sample_rate (int). 
	- Outputs: config map.

<b>Algorithm:</b>

For freq_from_note/2: 

	Step 1: Parse note to MIDI num (A4=69). 
	Step 2: freq = tuning * 2^((midi-69)/12).

For create_note/4: 

	Step 1: Compute freq. 
	Step 2: Build map with params.

<b>Configurability:</b> 

Tuning/velocity passed.

<b>Extensions:</b> 

Microtonal scales.


### lib/synth/drum/kick.ex

<b>Purpose:</b> 

Generates kick drum sounds via tuned sine sweeps. Specialized for percussion.

<b>Key Functions:</b>

generate/5: 

	- Inputs: start_freq (float), end_freq (float), duration (float), decay (float), sample_rate (int). 
	- Outputs: samples list. High-level behavior: Pitch-gliding thump.

<b>Algorithm:</b>

For generate/5: 

	Step 1: num_samples = duration *sample_rate. 
	Step 2: For t in 0..1 (normalized), freq = start + (end-start)t. 
	Step 3: Phase accum += 2π*freq/sample_rate. 
	Step 4: sample = sin(phase) * exp(-t/decay). 
	Step 5: List.

<b>Configurability:</b> 

All freqs/decay passed.

<b>Extensions:</b> 

Add noise layer.


### lib/synth/drum/noise.ex

<b>Purpose:</b> 

Produces white noise for snares/hats. Base for percussive textures.

<b>Key Functions:</b>

generate/3: 

	- Inputs: duration (float), amplitude (float), sample_rate (int). 
	- Outputs: samples list. High-level behavior: Random bursts.

<b>Algorithm:</b>

For generate/3: 

	Step 1: num_samples = duration * sample_rate. 
	Step 2: Use Stream.map to gen random floats -1..1, scale by amp.

<b>Configurability:</b> 

All args explicit.

<b>Extensions:</b> 

Colored noise via filters.


### lib/synth/wav_writer.ex

<b>Purpose:</b> 

Exports samples to WAV files. Final output stage for SDK.

<b>Key Functions:</b>

write/4: 

	- Inputs: samples (list), file_path (string), sample_rate (int), bit_depth (int). 
	- Outputs: :ok or error. High-level behavior: Binary encoding.

normalize/2: 

	- Inputs: samples, max_amp (float). 
	- Outputs: normalized list.

<b>Algorithm:</b>

For write/4: 

	Step 1: Normalize to -1..1. 
	Step 2: Scale to int range (e.g., for 16-bit: *32767). 
	Step 3: Pack header (RIFF, fmt, data chunks). 
	Step 4: Write binary.

For normalize/2: 

	Step 1: Find max abs. 
	Step 2: Divide each by max, multiply by max_amp.

<b>Configurability:</b> 

Rate/depth passed.

<b>Extensions:</b> 

Stereo support; other formats.

