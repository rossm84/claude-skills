#!/usr/bin/env bash
# manage-schedule.sh — Install or remove a recurring /impact-log <subcommand>
# entry in cron / launchd.
#
# Wraps generate-schedule-entry.sh's entry construction and adds the explicit
# write step. Per the consent model, this script DOES write to your crontab
# or LaunchAgents directory — but only when invoked with --action install or
# --action remove. Default behavior with no --action prints the planned
# action without writing anything (dry-run).
#
# USAGE:
#   ./manage-schedule.sh \
#     --action <install|remove|dry-run>           # required
#     [--subcommand <sub>]                        # default: rescue
#     [--cadence <weekly|monthly|<cron-expr>>]    # default: weekly
#     [--platform <auto|cron|launchd>]            # default: auto-detect
#     [--claude-path <path>]                      # default: $(which claude)
#     [--home <dir>]                              # default: $HOME (test override)
#
# EXAMPLES:
#   ./manage-schedule.sh --action install
#     # Install weekly rescue using the auto-detected platform
#
#   ./manage-schedule.sh --action remove --subcommand rescue
#     # Remove the previously-installed weekly rescue entry
#
#   ./manage-schedule.sh --action dry-run --subcommand "add --from quarterly"
#     # Show what would be installed without writing anything
#
# EXIT CODES:
#   0  — success
#   1  — install failed (entry not present after install) or remove failed
#        (no matching entry found)
#   2  — argument or environment error
#   3  — entry already installed (install) or generate-schedule-entry.sh
#        produced no output

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENERATE_SCRIPT="$SCRIPT_DIR/generate-schedule-entry.sh"

# -----------------------------------------------------------------------------
# Defaults
# -----------------------------------------------------------------------------
ACTION=""
SUBCOMMAND="rescue"
CADENCE="weekly"
PLATFORM="auto"
CLAUDE_PATH=""
HOME_OVERRIDE=""

# -----------------------------------------------------------------------------
# Argument parsing
# -----------------------------------------------------------------------------
while [ $# -gt 0 ]; do
  case "$1" in
    --action)      ACTION="$2"; shift 2 ;;
    --subcommand)  SUBCOMMAND="$2"; shift 2 ;;
    --cadence)     CADENCE="$2"; shift 2 ;;
    --platform)    PLATFORM="$2"; shift 2 ;;
    --claude-path) CLAUDE_PATH="$2"; shift 2 ;;
    --home)        HOME_OVERRIDE="$2"; shift 2 ;;
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

if [ -z "$ACTION" ]; then
  echo "ERROR: --action <install|remove|dry-run> is required." >&2
  exit 2
fi

case "$ACTION" in
  install|remove|dry-run) ;;
  *)
    echo "ERROR: --action must be one of: install, remove, dry-run. Got: '$ACTION'" >&2
    exit 2
    ;;
esac

# -----------------------------------------------------------------------------
# Resolve HOME (allow test override)
# -----------------------------------------------------------------------------
if [ -n "$HOME_OVERRIDE" ]; then
  HOME="$HOME_OVERRIDE"
fi

# -----------------------------------------------------------------------------
# Resolve platform
# -----------------------------------------------------------------------------
if [ "$PLATFORM" = "auto" ]; then
  case "$(uname -s)" in
    Darwin) PLATFORM="launchd" ;;
    Linux)  PLATFORM="cron" ;;
    *)      PLATFORM="cron" ;;
  esac
fi

case "$PLATFORM" in
  cron|launchd) ;;
  *)
    echo "ERROR: --platform must be 'auto', 'cron', or 'launchd'. Got: '$PLATFORM'" >&2
    exit 2
    ;;
esac

# -----------------------------------------------------------------------------
# Identifiers
# -----------------------------------------------------------------------------
LAUNCHD_LABEL="net.spotify.sessions.impact-log.${SUBCOMMAND// /-}"
PLIST_PATH="$HOME/Library/LaunchAgents/${LAUNCHD_LABEL}.plist"
CRON_MARKER="/impact-log $SUBCOMMAND"

# -----------------------------------------------------------------------------
# Resolve claude binary (only needed for install / dry-run)
# -----------------------------------------------------------------------------
if [ "$ACTION" != "remove" ]; then
  if [ -z "$CLAUDE_PATH" ]; then
    CLAUDE_PATH="$(command -v claude || true)"
    if [ -z "$CLAUDE_PATH" ]; then
      echo "ERROR: 'claude' not found in PATH. Pass --claude-path explicitly." >&2
      exit 2
    fi
  fi
fi

# -----------------------------------------------------------------------------
# Action: install / dry-run (need to build the entry)
# -----------------------------------------------------------------------------
if [ "$ACTION" = "install" ] || [ "$ACTION" = "dry-run" ]; then
  if [ ! -x "$GENERATE_SCRIPT" ]; then
    echo "ERROR: generate-schedule-entry.sh not executable at $GENERATE_SCRIPT" >&2
    exit 2
  fi

  GENERATED="$(HOME="$HOME" "$GENERATE_SCRIPT" \
    --subcommand "$SUBCOMMAND" \
    --cadence "$CADENCE" \
    --platform "$PLATFORM" \
    --claude-path "$CLAUDE_PATH")"

  if [ -z "$GENERATED" ]; then
    echo "ERROR: generate-schedule-entry.sh produced no output." >&2
    exit 3
  fi
fi

# -----------------------------------------------------------------------------
# Action: install (cron)
# -----------------------------------------------------------------------------
install_cron() {
  # Extract the cron line — first non-blank line beginning with whitespace+digits
  # in the generate output is the indented cron line.
  local cron_line
  cron_line=$(echo "$GENERATED" | awk '/^    [0-9*]/ {sub(/^    /,""); print; exit}')
  if [ -z "$cron_line" ]; then
    echo "ERROR: could not extract cron line from generate output." >&2
    exit 3
  fi

  local current
  current=$(crontab -l 2>/dev/null || true)

  if echo "$current" | grep -qF "$CRON_MARKER"; then
    echo "Already installed: $CRON_MARKER" >&2
    echo "Run with --action remove to remove first, or --action dry-run to preview." >&2
    exit 3
  fi

  if [ -n "$current" ]; then
    printf '%s\n%s\n' "$current" "$cron_line" | crontab -
  else
    printf '%s\n' "$cron_line" | crontab -
  fi

  if ! crontab -l 2>/dev/null | grep -qF "$CRON_MARKER"; then
    echo "ERROR: install failed — entry not found in crontab after write." >&2
    exit 1
  fi

  echo "Installed (cron): $CRON_MARKER"
  echo "Verify: crontab -l | grep impact-log"
  echo "Remove: $0 --action remove --subcommand \"$SUBCOMMAND\""
}

# -----------------------------------------------------------------------------
# Action: install (launchd)
# -----------------------------------------------------------------------------
install_launchd() {
  if [ -f "$PLIST_PATH" ]; then
    echo "Already installed: $PLIST_PATH" >&2
    echo "Run with --action remove to remove first, or --action dry-run to preview." >&2
    exit 3
  fi

  # Extract plist content from generate output (between <?xml and </plist>)
  local plist_content
  plist_content=$(echo "$GENERATED" | awk '/^<\?xml /,/^<\/plist>$/')
  if [ -z "$plist_content" ]; then
    echo "ERROR: could not extract plist content from generate output." >&2
    exit 3
  fi

  mkdir -p "$HOME/Library/LaunchAgents"
  printf '%s\n' "$plist_content" > "$PLIST_PATH"

  if ! launchctl load "$PLIST_PATH" 2>/dev/null; then
    rm -f "$PLIST_PATH"
    echo "ERROR: launchctl load failed for $PLIST_PATH" >&2
    exit 1
  fi

  if ! launchctl list 2>/dev/null | grep -qF "$LAUNCHD_LABEL"; then
    echo "ERROR: install failed — agent not loaded after launchctl load." >&2
    exit 1
  fi

  echo "Installed (launchd): $LAUNCHD_LABEL"
  echo "Verify: launchctl list | grep impact-log"
  echo "Remove: $0 --action remove --subcommand \"$SUBCOMMAND\""
}

# -----------------------------------------------------------------------------
# Action: remove (cron)
# -----------------------------------------------------------------------------
remove_cron() {
  local current filtered
  current=$(crontab -l 2>/dev/null || true)

  if [ -z "$current" ] || ! echo "$current" | grep -qF "$CRON_MARKER"; then
    echo "No entry found for $CRON_MARKER" >&2
    exit 1
  fi

  # grep -v exits 1 when no lines remain after filtering (and pipefail would
  # surface that), so capture the filtered output separately and tolerate the
  # empty case before piping into crontab.
  filtered=$(echo "$current" | grep -vF "$CRON_MARKER" || true)
  printf '%s\n' "$filtered" | crontab -
  echo "Removed (cron): $CRON_MARKER"
}

# -----------------------------------------------------------------------------
# Action: remove (launchd)
# -----------------------------------------------------------------------------
remove_launchd() {
  if [ ! -f "$PLIST_PATH" ]; then
    echo "No plist found at $PLIST_PATH" >&2
    exit 1
  fi

  launchctl unload "$PLIST_PATH" 2>/dev/null || true
  rm "$PLIST_PATH"
  echo "Removed (launchd): $LAUNCHD_LABEL"
}

# -----------------------------------------------------------------------------
# Action: dry-run (just print the planned action and the generated entry)
# -----------------------------------------------------------------------------
dry_run() {
  echo "=== Dry-run: would install ${SUBCOMMAND} via ${PLATFORM} ==="
  echo
  if [ "$PLATFORM" = "cron" ]; then
    echo "$GENERATED" | awk '/^    [0-9*]/ {sub(/^    /,""); print; exit}' | sed 's/^/  cron line: /'
  else
    echo "  plist path: $PLIST_PATH"
    echo "  label:      $LAUNCHD_LABEL"
  fi
  echo
  echo "Run with --action install to write."
}

# -----------------------------------------------------------------------------
# Dispatch
# -----------------------------------------------------------------------------
case "$ACTION:$PLATFORM" in
  install:cron)    install_cron ;;
  install:launchd) install_launchd ;;
  remove:cron)     remove_cron ;;
  remove:launchd)  remove_launchd ;;
  dry-run:*)       dry_run ;;
esac
