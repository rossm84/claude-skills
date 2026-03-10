# Claude Skills

Reusable skills for Claude Code and Claude Desktop. Teach Claude proven patterns so it gets things right the first time.

## Skills Included

### Community Tools (Spotify-specific)

| Skill | Description |
|-------|-------------|
| **khoros-community-search** | Query the Spotify Community via deployed API — no setup needed |
| **khoros-liql-reference** | LiQL syntax, authentication, known bugs, field reference |

### Backend Patterns (General-purpose)

| Skill | Description |
|-------|-------------|
| **graceful-degradation-apis** | Return partial data instead of errors when external services fail |
| **ai-model-fallback** | Multi-model AI resilience (Gemini → GPT fallback pattern) |
| **python-retry-resilience** | HTTP retries with exponential backoff and rate limit handling |
| **flask-cors-patterns** | CORS whitelist, preflight handling, credential support |
| **gmail-send-as-gcp** | Send email as a Google Group address from GCP using Gmail API + OAuth2 refresh token |
| **coda-readonly-integration** | Fetch structured data from Coda tables via REST API with pagination and caching |
| **appengine-cron-scheduling** | App Engine cron with user-configurable frequency (daily/weekly/custom) using a single hourly job |

### Frontend Patterns (General-purpose)

| Skill | Description |
|-------|-------------|
| **single-file-spa** | Build internal web tools as single HTML files, no build tools |
| **web-audio-synthesis** | Procedural UI sound effects — no audio files needed |
| **service-worker-caching** | Offline support with network-first caching and version management |

### Infrastructure (General-purpose)

| Skill | Description |
|-------|-------------|
| **firebase-internal-tools** | Firebase Hosting + App Engine + Firestore for internal tools |
| **excel-report-generation** | Professional multi-sheet Excel reports with openpyxl |
| **firestore-field-level-rules** | Per-field update restrictions using affectedKeys/hasOnly patterns |

## Setup: Claude Code

Copy the skill directories into your personal skills folder:

```bash
# Clone this repo
git clone <repo-url> ~/claude-skills

# Copy all skills
cp -r ~/claude-skills/*/ ~/.claude/skills/

# Or copy specific skills
cp -r ~/claude-skills/python-retry-resilience ~/.claude/skills/
cp -r ~/claude-skills/flask-cors-patterns ~/.claude/skills/
```

Skills activate automatically based on what you're doing. For example:
- "Add retry logic to my API client" → activates `python-retry-resilience`
- "Generate an Excel report" → activates `excel-report-generation`
- "Add sound effects to my web app" → activates `web-audio-synthesis`
- "Send email from a Google Group" → activates `gmail-send-as-gcp`
- "Add Firestore field-level permissions" → activates `firestore-field-level-rules`

## Setup: Claude Desktop (claude.ai)

Claude Desktop doesn't have a skills directory. Instead, use **Projects**:

1. Go to [claude.ai](https://claude.ai) and create a new Project
2. Open the skill file you want (e.g., `python-retry-resilience/SKILL.md`)
3. Copy the contents into the Project's **Custom Instructions**
4. Any conversation in that project will have the skill available

You can combine multiple skills in one project's instructions.

## Updating Skills

When skills are updated in this repo:

```bash
cd ~/claude-skills && git pull
cp -r ~/claude-skills/*/ ~/.claude/skills/
```
