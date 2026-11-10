#!/usr/bin/env bash
# Installs hey-oma for the current user: models, the `hey-oma` command, and a login service.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
DATA="$HOME/.local/share/hey-oma"
VOICE="https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/amy/medium/en_US-amy-medium.onnx"

for cmd in uv pw-record mpv curl unzip; do
  command -v "$cmd" >/dev/null || { echo "hey-oma needs '$cmd'. Install it (e.g. sudo pacman -S $cmd) and rerun."; exit 1; }
done

mkdir -p "$DATA/voice" "$HOME/.local/bin" "$HOME/.config/systemd/user"

if [ ! -d "$DATA/model" ]; then
  echo "Downloading speech recognition model (40MB)…"
  tmp="$(mktemp -d)"
  curl -fsSL https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip -o "$tmp/model.zip"
  unzip -q "$tmp/model.zip" -d "$tmp"
  mv "$tmp/vosk-model-small-en-us-0.15" "$DATA/model"
  rm -r "$tmp"
fi

if [ ! -f "$DATA/voice/en_US-amy-medium.onnx" ]; then
  echo "Downloading voice (60MB)…"
  curl -fsSL "$VOICE" -o "$DATA/voice/en_US-amy-medium.onnx"
  curl -fsSL "$VOICE.json" -o "$DATA/voice/en_US-amy-medium.onnx.json"
fi

ln -sf "$REPO/hey-oma" "$HOME/.local/bin/hey-oma"
cp "$REPO/hey-oma.service" "$HOME/.config/systemd/user/hey-oma.service"

echo "Preparing replies…"
"$HOME/.local/bin/hey-oma" --warm >/dev/null

systemctl --user daemon-reload
systemctl --user enable --now hey-oma
systemctl --user restart hey-oma

echo
echo "Done. Say: \"hey oma, open browser\""
echo "Watch what it hears: journalctl --user -u hey-oma -f"
