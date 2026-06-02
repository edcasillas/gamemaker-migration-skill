# MIDI to MP3 Audio Migration

Use this reference when legacy GM4/GM5/GMS1.4 music uses `.mid` or `.midi` files, especially for HTML5 or browser export.

MIDI files contain note and instrument events, not rendered audio. Render them through a synthesizer with a known SoundFont, then encode the rendered audio to MP3 or another target format.

## SoundFont Acquisition

This skill bundles the conversion scripts, but does not bundle the SoundFont binary:

- `scripts/convert-midi-to-mp3.ps1`
- `scripts/fetch-fluidr3mono-soundfont.sh`

When `FluidR3Mono_GM.sf3` is not already available, the agent should obtain it automatically with `scripts/fetch-fluidr3mono-soundfont.sh` before converting MIDI. The script first checks common system install paths, then downloads and extracts the Debian package.

Default output path:

```text
tools/soundfonts/FluidR3Mono_GM.sf3
```

SoundFont metadata:

- Source package: `fluidr3mono-gm-soundfont_2.315-7_all.deb` from Debian.
- Extracted file in package: `usr/share/sounds/sf3/FluidR3Mono_GM.sf3`.
- License: MIT, as documented by Debian for the package.
- Debian package SHA-256: `4098301bf29f4253c2f5799a844f42dd4aa733d91a210071ad16d7757dea51d6`.
- Extracted SoundFont SHA-256: `cda013d8c370a48ae8dad271e761078d2e77455488dabdedbfbe5fc76a38c682`.
- Debian package page: `https://packages.debian.org/bookworm/all/fluidr3mono-gm-soundfont`

Before public distribution, re-check the current package/license metadata and package checksum.

## Core Workflow

1. Locate MIDI files and identify which are active project resources.
2. Preserve original `.mid`/`.midi` files. Do not overwrite historical source assets.
3. Choose or fetch a SoundFont with clear source and license. For internal use, run `scripts/fetch-fluidr3mono-soundfont.sh` automatically when `tools/soundfonts/FluidR3Mono_GM.sf3` is missing.
4. Confirm `fluidsynth` and `ffmpeg` are installed.
5. Render MIDI to WAV with FluidSynth, then encode WAV to MP3 with FFmpeg.
6. Put converted audio in a staging folder outside the active game project unless the user explicitly asks to import or relink it.
7. Audition converted tracks where possible. MIDI output depends on the SoundFont and can differ from old system MIDI playback.
8. Document source files, output files, SoundFont metadata, tool versions when available, and follow-up validation in the project migration log.

## Script Usage

General conversion:

```bash
.codex/skills/migrate-gm4-gm5-gms14/scripts/fetch-fluidr3mono-soundfont.sh
```

```powershell
powershell -ExecutionPolicy Bypass -File .codex\skills\migrate-gm4-gm5-gms14\scripts\convert-midi-to-mp3.ps1 `
  -InputDir "path\to\midi" `
  -OutputDir "Assets\audio\converted-mp3" `
  -SoundFont "tools\soundfonts\FluidR3Mono_GM.sf3"
```

GMS1.4 registered sound conversion:

```powershell
powershell -ExecutionPolicy Bypass -File .codex\skills\migrate-gm4-gm5-gms14\scripts\convert-midi-to-mp3.ps1 `
  -InputDir "SukumGMS1\Sukum.gmx\sound\audio" `
  -GmxSoundDir "SukumGMS1\Sukum.gmx\sound" `
  -OutputDir "Assets\audio\converted-mp3" `
  -SoundFont "tools\soundfonts\FluidR3Mono_GM.sf3" `
  -Overwrite
```

When `-GmxSoundDir` is provided, the script reads `*.sound.gmx` files and converts only MIDI resources registered by the GMS1.4 project. Without it, the script converts every `.mid` and `.midi` in `-InputDir`.

## Game Maker Migration Notes

- GM4/GM5 projects often used MIDI music because older Windows/Game Maker runtimes could play it through system MIDI devices.
- GMS1.4 and especially HTML5/browser export should be treated as needing rendered audio. Do not assume a browser target can play MIDI.
- Avoid placing generated MP3 files inside the active `.gmx` project tree until the asset import/relink step is intentional.
- For GMS1.4, inspect `sound/*.sound.gmx` to distinguish active registered MIDI resources from duplicate loose files in `sound/audio/`.
- Keep source MIDI files in place for provenance and future re-rendering with a different SoundFont.
- If converted MP3 files are imported into GameMaker, update sound metadata deliberately and inspect GMX diffs for unrelated editor churn.
- Update sound kind, extension, data file, compression, and streaming metadata together. A resource that still points at `.mid` while the audio file has been converted is not migrated.
- Watch for legacy logic that polls whether music is playing on every key press or movement input. Replace it with a single background-music helper that owns stop/start/loop behavior.

## Validation

Validate:

- converted files exist for every active registered MIDI resource
- music starts only after acceptable browser audio unlock behavior
- looped music restarts correctly after room changes
- ending/cutscene cue points still match expected timing
- title/intro flows that advance on audio-ended events have a timeout or no-audio fallback
- converted output has been auditioned against an original executable, reference capture, or original MIDI playback when available

## Failure Modes

- FluidSynth opens an interactive prompt or hangs: check argument order and ensure the SoundFont path resolves to a real `.sf2` or `.sf3` file. Use `fluidsynth -ni -q -F out.wav -r 44100 soundfont.sf2 song.mid`.
- FluidSynth says the SoundFont file does not exist: pass an absolute resolved path, especially from PowerShell.
- FFmpeg is installed but cannot encode MP3: confirm the installed build supports `libmp3lame`, or encode to OGG/WAV if the target engine supports it.
- Converted music differs from the old game: document the difference before changing behavior. Historical playback may have depended on Windows system MIDI devices, the user's sound card, or another system synth.
