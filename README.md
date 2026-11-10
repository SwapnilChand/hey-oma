# hey oma

Talk to your [Omarchy](https://omarchy.org) desktop.

> "hey oma, open browser" → *"opening browser"* → your browser opens.

Runs fully offline, needs no LLM, and stays light enough to leave on all day. It only listens for the phrases it knows, so the rest of your conversation doesn't trigger anything.

## Install

```bash
git clone https://github.com/SwapnilChand/hey-oma
cd hey-oma
./install.sh
```

That's it. It starts now and every time you log in.

Needs `uv`, `mpv`, `curl`, `unzip` and PipeWire (all standard on Omarchy). Run `sudo pacman -S uv` if `uv` is missing.

## Things you can say

Start every command with **"hey oma"**.

| Say | Does |
|---|---|
| open browser · terminal · editor · obsidian | opens the app |
| open youtube · email · calendar · chat | opens the web app |
| play spotify | opens Spotify |
| play *any song name* | finds the song on Spotify |
| play music · pause · next song · previous song | controls Spotify |
| close window | closes the focused window |
| close spotify · browser · youtube · chat · obsidian | closes that app |

Watch what it hears:

```bash
journalctl --user -u hey-oma -f
```

## Add your own command

Open `hey-oma` and add a line to `COMMANDS`:

```python
"open files": "nautilus",
```

Optionally add what oma says back to `REPLIES`, then:

```bash
hey-oma --warm                       # makes the spoken reply once
systemctl --user restart hey-oma
```

Use everyday English words. The speech model doesn't know brand names like "whatsapp", which is why ChatGPT is "open chat".

## Optional: make oma talk in your voice

By default oma replies with a free local voice (Piper). To use your own cloned voice from [Cartesia](https://cartesia.ai):

```bash
mkdir -p ~/.config/hey-oma
cat > ~/.config/hey-oma/cartesia.env <<'EOF'
CARTESIA_API_KEY=sk_car_...
CARTESIA_VOICE_ID=your-voice-id
EOF
chmod 600 ~/.config/hey-oma/cartesia.env
hey-oma --warm
```

Every reply is generated once and saved in `~/.local/share/hey-oma/replies/`, named by what it says (`opening browser.wav`). After `--warm`, oma never calls the API for fixed replies. You can also drop in your own recordings under the same names.

## Optional: auto-play songs

Without this, "play *song*" opens Spotify's search with the song on top. To press play automatically, create an app at [developer.spotify.com](https://developer.spotify.com/dashboard) (the owner account needs Premium) and run:

```bash
cat > ~/.config/hey-oma/spotify.env <<'EOF'
SPOTIFY_CLIENT_ID=...
SPOTIFY_CLIENT_SECRET=...
EOF
```

## How it works

1. [Vosk](https://alphacephei.com/vosk/) listens to the mic, restricted to the known phrases, so it's accurate and cheap.
2. A match runs a shell command (the same ones Omarchy's keybindings use).
3. Oma speaks a saved reply: your Cartesia voice, then Piper, then espeak.

One Python file, no server, no LLM.

## Roadmap

**1. Fixed commands, fixed answers (now)**
Every question and answer is written down ahead of time and every reply is pre-recorded. It's instant and offline, and it costs nothing to run.

**2. More fixed questions with live answers**
Still no LLM, just templates filled with real values:
- "what time is it" → *"it's 10:42"*
- "battery" · "volume up / down" · "mute" · "brightness"
- "what's playing" · "switch to workspace two" · "lock screen"
- "remind me in ten minutes"
- Easier commands: a `commands.toml` instead of editing Python

**3. Do things on screen**
Drive any app through [hypruse](https://github.com/IlyasKhallouki/hypruse) (click, type, read the screen) for actions that have no command line.

**4. Ask anything**
A free-form voice assistant: speech to text (Superwhisper or Whisper), an LLM with desktop tools, and streaming speech back. Ask anything, get an answer, and have it run tasks in the background while you keep working.

PRs welcome, especially new commands for stage 2.

## Uninstall

```bash
systemctl --user disable --now hey-oma
rm ~/.local/bin/hey-oma ~/.config/systemd/user/hey-oma.service
rm -r ~/.local/share/hey-oma ~/.config/hey-oma
```

## License

MIT
