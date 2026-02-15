# applspeech

On-device speech transcription CLI for macOS, optimized for AI agents (JSON output, stdin/pipe friendly).

## Features

- Transcribe local files, `http(s)` URLs, `stdin` (`-`), and Telegram file IDs (`tg:`)
- JSON output mode for automation (`--format json`)
- `status` and `authorize` commands to check/request Speech and Microphone permissions
- Optional modern engine on macOS 26.0+ (`SpeechTranscriber` + `SpeechAnalyzer` + `AssetInventory`)

## Requirements

- Xcode 26 / Swift 6.2.3
- macOS 15+ (legacy engine via `SFSpeechRecognizer`)
- macOS 26.0+ (modern engine via `SpeechTranscriber`, model download via `AssetInventory`)

## Build

SwiftPM sandbox can fail in CI/agent environments. Use `--disable-sandbox`.

```bash
swift build -c release --disable-sandbox
./.build/release/applspeech --help
```

## Usage

```bash
applspeech --help
applspeech --version
```

### Transcribe

```bash
# Local file
applspeech transcribe audio.m4a

# JSON output (recommended for agents)
applspeech transcribe audio.m4a --format json

# Pick locale
applspeech transcribe audio.m4a --locale es-ES --format json

# Force engine (auto | legacy | modern)
applspeech transcribe audio.m4a --engine auto --format json
applspeech transcribe audio.m4a --engine legacy --format json
applspeech transcribe audio.m4a --engine modern --format json

# URL input
applspeech transcribe https://example.com/audio.wav --format json

# stdin/pipe input
curl -L https://example.com/audio.m4a | applspeech transcribe - --format json

# Telegram input (requires TELEGRAM_BOT_TOKEN)
applspeech transcribe tg:<telegram_file_id> --format json
```

`--engine auto` behavior:

- If running on macOS 26.0+ and a SpeechTranscriber model is installed for the locale, uses `SpeechTranscriber`
- Otherwise falls back to `SFSpeechRecognizer`

### Status (Permissions + Model Availability)

```bash
applspeech status --format json
applspeech status --locale es-ES --format json
```

This prints a JSON status object including:

- `permissions.speechRecognition` (Speech permission)
- `permissions.microphone` (Microphone permission)
- `engines.sfSpeechRecognizer` availability
- `engines.speechTranscriber` model availability/installation state

### Authorize (Trigger Prompts, Download Model)

```bash
# Request Speech permission only
applspeech authorize --format json

# Also request Microphone permission
applspeech authorize --microphone --format json

# On macOS 26.0+, download/install the modern model for the locale (if supported)
applspeech authorize --locale es-ES --download-model --format json
```

## Output Notes

- `--format json` outputs success JSON on `stdout`.
- Errors are emitted as `{"ok":false,"error":{...}}` JSON on `stderr` (the process may still exit with code 0).

## OpenClaw Skill Example

This repo includes a sample OpenClaw/AgentSkills skill file at:

- `skills/applspeech/SKILL.md`

It follows the AgentSkills/OpenClaw skill conventions and includes a recommended workflow:

1. Call `applspeech status --format json` to verify permissions and (on macOS 26+) model availability
2. If needed, call `applspeech authorize` to trigger prompts and optionally install the model
3. Call `applspeech transcribe ... --format json` and parse the returned JSON

## Privacy

applspeech is intended for on-device transcription. It does not upload audio to third-party services.

## References

- Apple Speech framework docs: https://developer.apple.com/documentation/speech
- SpeechTranscriber: https://developer.apple.com/documentation/speech/speechtranscriber
- SpeechAnalyzer: https://developer.apple.com/documentation/speech/speechanalyzer
- AssetInventory: https://developer.apple.com/documentation/speech/assetinventory

