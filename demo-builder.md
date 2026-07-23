---
name: demo-builder
description: Build polished demo presentations for any project. Single-file SPA with narration, video export, and clean non-AI-looking design. Reusable pipeline.
triggers:
  - build a demo
  - make a demo
  - demo presentation
  - project demo
  - demo video
  - presentation for
---

# Demo Builder Skill

Build a polished demo presentation for any project. Produces a single-file SPA (web) + rendered video (MP4/WebM/GIF/vertical).

Reference implementation: `/home/rossmiller/public/porch-demo/`

## Step 1: Structure

Create a directory under `~/public/<project>-demo/` with:

```
<project>-demo/
  index.html          # Single-file SPA (HTML + CSS + JS, no build step)
  render-video.py     # Headless Chrome + ffmpeg video pipeline
  audio/              # Default voice narration clips + ambient.mp3
  audio-thomas/       # Alt voice 1
  audio-connor/       # Alt voice 2
```

## Step 2: Slide Deck (index.html)

Single-file SPA. No frameworks, no build tools. Structure:

1. **Title** - Project name + one-line description + metadata
2. **Problem** - What's broken / missing (3 columns with dividers)
3. **Solution** - How this project fixes it (3 columns)
4. **In Action** - Real data / screenshots / live demo content
5. **Features** - Bullet list with dot markers, staggered fade-in
6. **Architecture** - How it's built (node -> arrow -> node flow)
7. **Stats** - Animated counters (data-count attribute)
8. **Roadmap** - Timeline component (Now / Next / Planned / Vision)
9. **End** - Project name + tagline + URL

Adapt slide count and content to the project. Not every project needs all 9.

### Design Rules (non-negotiable)

These prevent the "obviously AI-generated" look:

**DO:**
- Dark minimal palette: `#08080c` bg, ONE accent color, grayscale for text
- Inter font (or system-ui), tight letter-spacing on headlines (-0.03 to -0.04em)
- Solid backgrounds, 1px `#1c1c24` borders only where needed
- 80-100px section padding, generous whitespace
- Staggered fade-in animations (0.15s delay increment)
- Text dividers between columns
- Simple dot markers for lists
- Letter-initial avatars for people/agents

**DO NOT:**
- Particle networks, glow orbs, animated backgrounds
- Glassmorphism (backdrop-filter, rgba transparent cards)
- Multi-color gradients or shimmer text
- Badge pills ("The Problem", "The Solution")
- Emoji as section icons
- 3-card glass grids with shadows
- Decorative animations that don't clarify content

### Audio System

```javascript
// Pre-generated MP3 playback, NOT browser TTS
// Audio-driven slide advancement (ended event triggers next slide)
// Fallback timer only when audio is muted
// 3 switchable voices (V key)
// Subtitle bar synced to narration (S key toggle)
// Ambient pad underneath narration (M key toggle)
```

### Controls

Keyboard: Space (play/pause), Arrows (nav), M (mute), V (voice), S (subtitles)
Click-to-start overlay on load.

## Step 3: Generate Narration

Uses `edge-tts` (Microsoft neural TTS, free, no API key).

```bash
pip3 install --user --break-system-packages edge-tts
```

Write narration text for each slide, then generate:

```bash
# Primary voice (British English)
edge-tts --voice en-GB-RyanNeural --text "Narration text" --write-media audio/slide01.mp3

# Alt voices
edge-tts --voice en-GB-ThomasNeural --text "Narration text" --write-media audio-thomas/slide01.mp3
edge-tts --voice en-IE-ConnorNeural --text "Narration text" --write-media audio-connor/slide01.mp3
```

Good voices to consider:
- `en-GB-RyanNeural` - clear, professional British male
- `en-GB-ThomasNeural` - warmer British male
- `en-IE-ConnorNeural` - Irish male, slightly different feel
- `en-AU-WilliamNeural` - Australian male
- `en-GB-SoniaNeural` - British female

Generate ambient track:

```bash
ffmpeg -y -f lavfi -i "sine=frequency=80:duration=180,volume=0.03" \
  -f lavfi -i "sine=frequency=120:duration=180,volume=0.02" \
  -f lavfi -i "sine=frequency=200:duration=180,volume=0.015" \
  -filter_complex "[0][1][2]amix=inputs=3,aecho=0.8:0.88:60:0.4,lowpass=f=300" \
  -t 180 -q:a 9 audio/ambient.mp3
```

## Step 4: Render Video

Copy `render-video.py` from the Porch demo as a starting point. Adapt:
- `SLIDE_COUNT` and `SLIDE_DURATIONS` to match your deck
- `KEN_BURNS` array (zoom/pan per slide)
- Crossfade transition types

Requires:

```bash
pip3 install --user --break-system-packages pyppeteer
python3 -m pyppeteer.command install
# May need: sudo apt install -y libnss3 libatk-bridge2.0-0 libdrm2 libxkbcommon0 libgbm1 libxshmfence1 libasound2t64
```

```bash
python3 render-video.py ryan all
```

Outputs:
- `.mp4` (H.264 + AAC) - general use
- `.webm` (VP9 + Opus) - web embedding
- `-preview.gif` (480p 8fps, 30s) - Slack/chat preview
- `-vertical.mp4` (1080x1920) - mobile/Stories

## Step 5: Serve Web Version

```bash
python3 -m http.server 8888
```

## Step 6: Sync Timing

Get actual audio durations and update both files:

```bash
for f in audio/slide*.mp3; do echo -n "$f: "; ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$f"; done
```

Update `SLIDE_DURATIONS` in render-video.py and `fallbackDurations` in index.html (add ~2s buffer).

## Checklist

- [ ] Slide content written (adapt slide count to project)
- [ ] Design rules followed (no AI tells)
- [ ] Narration text written and matches subtitle array
- [ ] Audio generated for at least 1 voice
- [ ] Ambient track generated
- [ ] Timing synced (audio durations -> both files)
- [ ] Web version tested in browser
- [ ] Video rendered and verified (no overlay, proper slide advancement)
- [ ] Formats exported as needed
