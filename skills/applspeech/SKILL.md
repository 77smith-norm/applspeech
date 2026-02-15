---
name: applspeech
description: On-device speech transcription via the applspeech CLI (JSON output, status/authorize workflow).
homepage: https://github.com/77smith-norm/applspeech
metadata: {"openclaw":{"category":"cli"},"applspeech":{"binary":"applspeech","json_default":false}}
---

# applspeech (OpenClaw Skill)

Use this skill to transcribe audio with the `applspeech` CLI and return machine-parseable results.

## What To Run

Preferred pattern for agents:

1. Verify permissions + engine readiness
```bash
applspeech status --locale en-US --format json
```

2. If not ready, trigger the required prompts (Speech permission) and optionally:
- request microphone permission (for live transcription workflows)
- download/install the SpeechTranscriber model (macOS 26.0+ only)
```bash
applspeech authorize --locale en-US --format json
applspeech authorize --locale en-US --microphone --format json
applspeech authorize --locale en-US --download-model --format json
```

3. Transcribe (JSON output)
```bash
applspeech transcribe "<file-or-url-or-'-' or 'tg:<file_id>'>" --locale en-US --format json --engine auto
```

## How To Interpret Output

### Success

`transcribe --format json` returns JSON on `stdout`:

```json
{
  "text": "…",
  "file": "…",
  "language": "en-US",
  "engine": "auto|sfSpeechRecognizer|speechTranscriber"
}
```

### Errors

Errors are emitted as JSON on `stderr`:

```json
{"ok":false,"error":{"code":"…","message":"…"}}
```

Note: the process can still exit with code 0 on errors. Always check for `ok:false` error JSON on `stderr`.

## Engine Selection

- `--engine auto`: prefer `SpeechTranscriber` if running on macOS 26.0+ and the model is installed; otherwise
  use `SFSpeechRecognizer`.
- `--engine legacy`: force `SFSpeechRecognizer` (`SFSpeechURLRecognitionRequest`).
- `--engine modern`: force `SpeechTranscriber` (macOS 26.0+ only; requires installed model).

## Safety / Privacy

- Transcription text can contain sensitive data. Avoid logging it unless the user requests it.
- Use `--format json` and pass only the needed fields to downstream tools.

