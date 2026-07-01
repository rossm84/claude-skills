---
name: youtube-transcript
description: Use when fetching, reading, or summarizing YouTube video transcripts. Extracts captions/subtitles from any YouTube video for analysis, quoting, or research.
---

# YouTube Transcript Extraction

## Setup (one-time)
```bash
pip3 install youtube-transcript-api
```

## Usage

### Get transcript
```python
from youtube_transcript_api import YouTubeTranscriptApi

video_id = "dQw4w9WgXcQ"  # extract from URL: youtube.com/watch?v=VIDEO_ID
transcript = YouTubeTranscriptApi.get_transcript(video_id)

# Full text
full_text = " ".join(entry['text'] for entry in transcript)
print(full_text)

# With timestamps
for entry in transcript:
    mins = int(entry['start'] // 60)
    secs = int(entry['start'] % 60)
    print(f"[{mins:02d}:{secs:02d}] {entry['text']}")
```

### Get transcript in a specific language
```python
transcript = YouTubeTranscriptApi.get_transcript(video_id, languages=['en', 'en-US'])
```

### List available transcripts
```python
transcript_list = YouTubeTranscriptApi.list_transcripts(video_id)
for t in transcript_list:
    print(f"{t.language} ({t.language_code}) - {'auto' if t.is_generated else 'manual'}")
```

### Extract video ID from URL
```python
import re
def extract_video_id(url):
    patterns = [
        r'(?:v=|\/v\/|youtu\.be\/)([a-zA-Z0-9_-]{11})',
        r'(?:embed\/)([a-zA-Z0-9_-]{11})',
    ]
    for p in patterns:
        m = re.search(p, url)
        if m:
            return m.group(1)
    return None
```

### Save transcript to file
```python
import json
with open('/tmp/transcript.json', 'w') as f:
    json.dump(transcript, f, indent=2)

# Or as plain text
with open('/tmp/transcript.txt', 'w') as f:
    f.write(full_text)
```

## Tips
- Auto-generated captions are available for most videos but may have errors
- Manual captions are more accurate when available
- Some videos have captions disabled; the API will raise an error
- For very long videos, consider chunking the transcript for analysis
