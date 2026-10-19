# 🎬 Auto-Subtitles — Claude Code Skill



> Voice-driven hardcoded subtitles for any vertical / horizontal / square video. Whisper → smart-chunks → burn-in with your font and brand plate. One command.

A skill for [Claude Code](https://www.anthropic.com/claude-code) that turns any video with voiceover into a video with **clean burned-in subtitles**: Whisper transcribes speech with word-level timestamps, the skill smart-chunks into 2-5 word segments by punctuation and pauses, and ffmpeg burns them in with your font and brand colors.

🇷🇺 [Русская версия](./README.md)

---

## Why

CapCut and Premiere **strip styling from .srt/.ass files** — you get plain Arial. To get branded subtitles on 38 videos, you either pay an editor 38 hours, or let an AI do it in 10 minutes.

This skill is the second option. Accurate timing, meaningful chunks, any font, any colors.

---

## Features

- ✅ Whisper `large-v3` — best accuracy model, **95-99% on most languages**
- ✅ **Word-level timestamps** — subtitles stay in sync with voice, no drift
- ✅ **Smart-chunking** — splits at punctuation and pauses, 2-5 word chunks, not rigid N-word blocks
- ✅ **Hallucination filter** — removes "Subtitles by..." and other Whisper artifacts
- ✅ **Any font** — `.otf`/`.ttf` from any folder
- ✅ **Any palette** — text color, plate color, outline all configurable
- ✅ **Any frame size** — 9:16 / 16:9 / 1:1 with size presets
- ✅ **Any language** — anything Whisper supports (en, ru, es, fr, de, zh, +90 more)
- ✅ **Glossary** — pass brand names, jargon, person names to Whisper for better recognition

---

## Installation

1. The skill:

```bash
mkdir -p ~/.claude/skills/auto-subtitles
curl -fsSL https://raw.githubusercontent.com/sketch-man/claude-skill-auto-subtitles/main/SKILL.md \
  -o ~/.claude/skills/auto-subtitles/SKILL.md
```

2. Dependencies:

```bash
# macOS Apple Silicon (fast, recommended)
pip install mlx-whisper
brew install ffmpeg

# Linux/Windows
pip install openai-whisper
# ffmpeg: apt install ffmpeg / scoop install ffmpeg
```

3. Restart Claude Code. The skill loads automatically.

---

## Usage

Open Claude Code in your video folder and describe what you want:

```
Auto-subtitle all videos in this folder.
Font: /Users/me/fonts/Inter-Bold.otf
Colors: white text, dark blue plate rgba(20,30,60,0.7)
Frame: 9:16
Language: english
Brand vocabulary: Anthropic, Claude, sonnet, opus
```

Claude will:
1. Run Whisper large-v3 on each video
2. Get JSON with word-level timestamps
3. Cut into semantic 2-5 word chunks
4. Generate ASS with your style
5. Use ffmpeg to burn subtitles into the video
6. Output to `out/`

On M1/M2/M3 → ~30-60 sec per minute of video.

---

## Triggers

The skill activates on phrases like:

- "auto subtitles", "burn subtitles", "voice to subtitles"
- "hardcoded captions", "TikTok subtitles", "Reels captions"
- "вшей субтитры", "автотитры", "субтитры по голосу"

---

## Configuration

All settings live inside `SKILL.md` and the Python script Claude generates:

| Param | What | Default for 9:16 |
|---|---|---|
| `FONT_NAME` | Font family (must match a file in `FONTS_DIR`) | — |
| `FONT_SIZE` | Font size in pt | 60 |
| `FONTS_DIR` | Folder with `.otf`/`.ttf` files | — |
| `STRIP_Y` | Plate top edge from video top, px | 140 |
| `STRIP_H` | Plate height, px | 140 |
| `PLATE_COLOR` | Plate color (ffmpeg syntax) | `black@0.55` |
| `TEXT_COLOR` | Text color (ASS BGR hex) | `&H00FFFFFF` (white) |
| `MIN_WORDS` / `MAX_WORDS` | Words per chunk | 2 / 5 |
| `MAX_CHARS` | Max chars per chunk | 32 |
| `PAUSE_THRESHOLD` | Pause to split on, sec | 0.40 |

---

## Stack

- **mlx-whisper** (Apple Silicon optimization) or **openai-whisper** (cross-platform)
- **ffmpeg + libass** — subtitle rendering
- Python 3.9+

---

## License

MIT — use it, fork it, customize for your clients, charge money.

---

## Author

[sketch-man](https://github.com/sketch-man) — AI × marketing × video.

- 📺 [AI Vibe](https://t.me/ai_vibe) — personal channel (Russian)
- 💼 [AI Toolz for Business](https://t.me/aitoolz_business) — AI tools for business (Russian)

⭐ if you found this useful, share with your marketing/video friends.
