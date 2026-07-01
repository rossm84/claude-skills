# `/impact-log schedule` — Full Reference

> Generate a cron / launchd entry for recurring `/impact-log` runs. The skill prints; you install. See the [routing layer](../SKILL.md) for navigation.

---

## When to use

Hands-off scheduled sync — typically a weekly `/impact-log rescue` to catch evidence about to expire from ephemeral sources, or a monthly `/impact-log add --from quarterly` to fold the latest team-update synthesis.

If you'd prefer to run `/impact-log rescue` manually whenever you remember, skip this — manual entry is the default and stays consent-aligned.

## Why this is opt-in

The skill prints a cron line or launchd plist. **It does not modify your crontab or `LaunchAgents` directory.** You take the explicit `crontab -e` (or `launchctl load`) step yourself, so consent stays intrinsic — no special permission flow, no escalation, no surprise scheduled jobs.

For the fully-automated path (`schedule install` / `schedule remove`), see [`manage-schedule.sh`](manage-schedule.sh) and the corresponding rows in the [parent SKILL.md](../SKILL.md) subcommand table.

## Why local cron / launchd, not cloud schedulers?

Several agentic clients provide scheduling primitives, but cloud-hosted schedulers run away from your machine. impact-log's auto-population uses MCP servers (`atlassian-mcp`, `slack-search`, etc.) that authenticate locally with your Spotify SSO. A cloud-side runner doesn't have those credentials or that network path. Local cron / launchd runs where the auth lives, which is why it's the practical scheduled path here.

**Cross-model note:** The current helper scripts generate Claude CLI invocations (`claude -p "/impact-log ..."`). Non-Claude agents can still use the impact-log workflow manually, but scheduled runs need a client-specific runner command before installation. See [`../../../../../docs/cross-model-compatibility.md`](../../../../../docs/cross-model-compatibility.md) for the marketplace-wide compatibility note and transpiler follow-up.

## Usage

```bash
# From the skill directory:
./references/generate-schedule-entry.sh \
  [--subcommand <sub>]                       # default: rescue
  [--cadence <weekly|monthly|<cron-expr>>]   # default: weekly
  [--platform <auto|cron|launchd>]           # default: auto-detect
  [--claude-path <path>]                     # default: $(which claude)
```

### Examples

**Weekly `rescue` on macOS** (auto-detected → launchd):

```bash
./generate-schedule-entry.sh
```

Prints a launchd plist with install instructions (`launchctl load ...`).

**Weekly `rescue` on Linux/WSL** (auto-detected → cron):

```bash
./generate-schedule-entry.sh
```

Prints a cron line for `crontab -e`.

**Monthly auto-add from `/team-update quarterly`:**

```bash
./generate-schedule-entry.sh --cadence monthly --subcommand "add --from quarterly"
```

**Custom cron expression — Mondays at 8am:**

```bash
./generate-schedule-entry.sh --cadence "0 8 * * 1"
```

## What the schedule entry does

The cron line / launchd entry runs:

```
$(which claude) -p "/impact-log <subcommand>"
```

— in non-interactive mode, with output redirected to `~/.claude/impact-log-schedule.log`. The user remains responsible for keeping the `claude` CLI authenticated; if the CLI's session expires, the scheduled run will fail and the failure will be logged at that path.

## Verifying after install

**Cron:**
```bash
crontab -l | grep impact-log
```

**launchd:**
```bash
launchctl list | grep impact-log
```

**Check the log:**
```bash
tail -50 ~/.claude/impact-log-schedule.log
```

## Removing the schedule

**Cron:** run `crontab -e` and delete the line.

**launchd:**
```bash
launchctl unload ~/Library/LaunchAgents/net.spotify.sessions.impact-log.<subcommand>.plist
rm ~/Library/LaunchAgents/net.spotify.sessions.impact-log.<subcommand>.plist
```

## Testing

The script's logic (cadence resolution, platform detection, cron-expression validation, plist generation) has stdlib bash unit tests at [`test_generate-schedule-entry.sh`](test_generate-schedule-entry.sh). Run with `bash test_generate-schedule-entry.sh`.
