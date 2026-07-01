#!/usr/bin/env bash
# generate-schedule-entry.sh — Print a cron / launchd entry for recurring
# /impact-log <subcommand> runs.
#
# This script does NOT modify your crontab or LaunchAgents directory. It
# prints the entry and the install/remove instructions; you take the
# explicit step yourself. Consent stays intrinsic to the flow.
#
# USAGE:
#   ./generate-schedule-entry.sh \
#     [--subcommand <sub>]            # default: rescue
#     [--cadence <weekly|monthly|<cron-expr>>]  # default: weekly
#     [--platform <auto|cron|launchd>]          # default: auto-detect
#     [--claude-path <path>]                    # default: $(which claude)
#
# EXAMPLES:
#   ./generate-schedule-entry.sh
#     # Weekly rescue, auto-detected platform
#
#   ./generate-schedule-entry.sh --cadence monthly --subcommand "add --from quarterly"
#     # Monthly auto-add from quarterly synthesis
#
#   ./generate-schedule-entry.sh --cadence "0 8 * * 1" --platform cron
#     # Custom: Mondays at 8am, force cron output

set -euo pipefail

# -----------------------------------------------------------------------------
# Defaults
# -----------------------------------------------------------------------------
SUBCOMMAND="rescue"
CADENCE="weekly"
PLATFORM="auto"
CLAUDE_PATH=""

# -----------------------------------------------------------------------------
# Argument parsing
# -----------------------------------------------------------------------------
while [ $# -gt 0 ]; do
  case "$1" in
    --subcommand) SUBCOMMAND="$2"; shift 2 ;;
    --cadence)    CADENCE="$2"; shift 2 ;;
    --platform)   PLATFORM="$2"; shift 2 ;;
    --claude-path) CLAUDE_PATH="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,/^$/p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Run with --help for usage." >&2
      exit 2
      ;;
  esac
done

# -----------------------------------------------------------------------------
# Resolve claude binary
# -----------------------------------------------------------------------------
if [ -z "$CLAUDE_PATH" ]; then
  CLAUDE_PATH="$(command -v claude || true)"
  if [ -z "$CLAUDE_PATH" ]; then
    echo "ERROR: 'claude' not found in PATH. Pass --claude-path explicitly." >&2
    exit 1
  fi
fi

# -----------------------------------------------------------------------------
# Resolve cron expression from cadence
# -----------------------------------------------------------------------------
case "$CADENCE" in
  weekly)  CRON_EXPR="0 9 * * 1" ;;        # Mondays at 9am
  monthly) CRON_EXPR="0 9 1 * *" ;;        # 1st of month at 9am
  *)
    # Treat as literal cron expression — minimal validation: 5 space-separated fields
    if [ "$(echo "$CADENCE" | awk '{print NF}')" != "5" ]; then
      echo "ERROR: --cadence must be 'weekly', 'monthly', or a 5-field cron expression." >&2
      echo "Got: '$CADENCE'" >&2
      exit 2
    fi
    CRON_EXPR="$CADENCE"
    ;;
esac

# -----------------------------------------------------------------------------
# Resolve platform
# -----------------------------------------------------------------------------
if [ "$PLATFORM" = "auto" ]; then
  case "$(uname -s)" in
    Darwin) PLATFORM="launchd" ;;
    Linux)  PLATFORM="cron" ;;
    *)      PLATFORM="cron" ;;  # WSL, BSDs, etc. typically have cron
  esac
fi

# -----------------------------------------------------------------------------
# Compose log path
#   - cron's shell expands $HOME at execution, so the literal "\$HOME/..."
#     form is portable across users when pasted into a crontab.
#   - launchd does NOT perform env-var substitution on plist string values
#     (StandardOutPath / StandardErrorPath / WorkingDirectory / ProgramArguments).
#     For launchd output, $HOME must be resolved to an absolute path at script
#     time so the plist contains a literal /Users/<name>/.claude/... path.
# -----------------------------------------------------------------------------
LOG_PATH_CRON="\$HOME/.claude/impact-log-schedule.log"
LOG_PATH_LAUNCHD="$HOME/.claude/impact-log-schedule.log"

# -----------------------------------------------------------------------------
# Emit the entry
# -----------------------------------------------------------------------------
case "$PLATFORM" in
  cron)
    cat <<EOF
=== Scheduled $SUBCOMMAND entry (cron) ===

Add this line to your crontab (run \`crontab -e\`):

    $CRON_EXPR $CLAUDE_PATH -p "/impact-log $SUBCOMMAND" >> $LOG_PATH_CRON 2>&1

Cadence: $CADENCE  (cron expression: $CRON_EXPR)
Subcommand: /impact-log $SUBCOMMAND
Log path: $LOG_PATH_CRON  (cron's shell expands \$HOME at run time)

Install:
    crontab -e
    # paste the line above, save, exit

Remove later:
    crontab -e
    # delete the line above, save, exit

Verify after install:
    crontab -l | grep impact-log
EOF
    ;;
  launchd)
    LAUNCHD_LABEL="net.spotify.sessions.impact-log.${SUBCOMMAND// /-}"
    PLIST_PATH="\$HOME/Library/LaunchAgents/${LAUNCHD_LABEL}.plist"
    # Convert cron expression to launchd StartCalendarInterval (best-effort)
    CRON_MIN=$(echo "$CRON_EXPR" | awk '{print $1}')
    CRON_HOUR=$(echo "$CRON_EXPR" | awk '{print $2}')
    CRON_DOM=$(echo "$CRON_EXPR" | awk '{print $3}')
    CRON_DOW=$(echo "$CRON_EXPR" | awk '{print $5}')
    cat <<EOF
=== Scheduled $SUBCOMMAND entry (launchd) ===

Save this plist to $PLIST_PATH:

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>$LAUNCHD_LABEL</string>
    <key>ProgramArguments</key>
    <array>
      <string>$CLAUDE_PATH</string>
      <string>-p</string>
      <string>/impact-log $SUBCOMMAND</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
      <key>Minute</key>
      <integer>$CRON_MIN</integer>
      <key>Hour</key>
      <integer>$CRON_HOUR</integer>
EOF
    if [ "$CRON_DOM" != "*" ]; then
      echo "      <key>Day</key>"
      echo "      <integer>$CRON_DOM</integer>"
    fi
    if [ "$CRON_DOW" != "*" ]; then
      echo "      <key>Weekday</key>"
      echo "      <integer>$CRON_DOW</integer>"
    fi
    cat <<EOF
    </dict>
    <key>StandardOutPath</key>
    <string>$LOG_PATH_LAUNCHD</string>
    <key>StandardErrorPath</key>
    <string>$LOG_PATH_LAUNCHD</string>
    <key>RunAtLoad</key>
    <false/>
  </dict>
</plist>

Cadence: $CADENCE  (cron expression: $CRON_EXPR)
Subcommand: /impact-log $SUBCOMMAND
Log path: $LOG_PATH_LAUNCHD  (resolved at install time — launchd does not expand \$HOME in plist strings)

Install:
    mkdir -p \$HOME/Library/LaunchAgents
    # save the plist above to: $PLIST_PATH
    launchctl load $PLIST_PATH

Remove later:
    launchctl unload $PLIST_PATH
    rm $PLIST_PATH

Verify after install:
    launchctl list | grep impact-log
EOF
    ;;
  *)
    echo "ERROR: --platform must be 'auto', 'cron', or 'launchd'. Got: '$PLATFORM'" >&2
    exit 2
    ;;
esac
