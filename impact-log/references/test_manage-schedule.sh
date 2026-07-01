#!/usr/bin/env bash
# test_manage-schedule.sh — Stdlib bash tests for manage-schedule.sh.
#
# Run:
#   bash test_manage-schedule.sh
#
# Coverage:
#   - Argument validation (required --action, invalid action, invalid platform)
#   - Dry-run output for cron and launchd
#   - Install / remove for cron and launchd, using PATH-injected mocks for
#     crontab and launchctl plus an isolated HOME for the plist directory.
#   - Idempotency guard: install fails when an entry is already present.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/manage-schedule.sh"

PASS=0
FAIL=0
FAIL_DETAILS=()

assert_eq() {
  local actual="$1"
  local expected="$2"
  local label="$3"
  if [ "$actual" = "$expected" ]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    FAIL_DETAILS+=("FAIL: $label
  expected: $expected
  actual:   $actual")
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local label="$3"
  if echo "$haystack" | grep -qF "$needle"; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    FAIL_DETAILS+=("FAIL: $label
  expected to contain: $needle
  in: $haystack")
  fi
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  local label="$3"
  if echo "$haystack" | grep -qF "$needle"; then
    FAIL=$((FAIL + 1))
    FAIL_DETAILS+=("FAIL: $label
  expected NOT to contain: $needle
  in: $haystack")
  else
    PASS=$((PASS + 1))
  fi
}

# -----------------------------------------------------------------------------
# Mock setup
# -----------------------------------------------------------------------------
MOCK_DIR=$(mktemp -d -t manage-schedule-mock.XXXXXX)
trap 'rm -rf "$MOCK_DIR"' EXIT

# crontab mock — backing file at $MOCK_DIR/crontab.txt
cat > "$MOCK_DIR/crontab" <<'EOF'
#!/usr/bin/env bash
# Mock crontab: -l reads $CRONTAB_FILE; - writes from stdin to $CRONTAB_FILE
case "${1:-}" in
  -l) [ -f "$CRONTAB_FILE" ] && cat "$CRONTAB_FILE" || exit 1 ;;
  -)  cat > "$CRONTAB_FILE" ;;
  *)  echo "mock crontab: unsupported arg: ${1:-}" >&2; exit 2 ;;
esac
EOF
chmod +x "$MOCK_DIR/crontab"

# launchctl mock — load creates $LAUNCHCTL_LOADED file; list checks for it
cat > "$MOCK_DIR/launchctl" <<'EOF'
#!/usr/bin/env bash
case "${1:-}" in
  load)   plist="${2:-}"; label=$(basename "$plist" .plist); echo "$label" >> "$LAUNCHCTL_LOADED" ;;
  unload) plist="${2:-}"; label=$(basename "$plist" .plist); [ -f "$LAUNCHCTL_LOADED" ] && grep -vxF "$label" "$LAUNCHCTL_LOADED" > "$LAUNCHCTL_LOADED.tmp" && mv "$LAUNCHCTL_LOADED.tmp" "$LAUNCHCTL_LOADED" ;;
  list)   [ -f "$LAUNCHCTL_LOADED" ] && cat "$LAUNCHCTL_LOADED" ;;
  *)      echo "mock launchctl: unsupported arg: ${1:-}" >&2; exit 2 ;;
esac
EOF
chmod +x "$MOCK_DIR/launchctl"

run_with_mocks() {
  local home_dir="$1"
  shift
  CRONTAB_FILE="$MOCK_DIR/crontab.txt" \
  LAUNCHCTL_LOADED="$MOCK_DIR/launchctl-loaded.txt" \
  PATH="$MOCK_DIR:$PATH" \
  "$SCRIPT" --home "$home_dir" "$@"
}

reset_mocks() {
  rm -f "$MOCK_DIR/crontab.txt" "$MOCK_DIR/launchctl-loaded.txt"
}

# -----------------------------------------------------------------------------
# Argument validation
# -----------------------------------------------------------------------------
out=$("$SCRIPT" 2>&1 || true)
assert_contains "$out" "ERROR: --action <install|remove|dry-run> is required." "missing --action errors out"

out=$("$SCRIPT" --action foo 2>&1 || true)
assert_contains "$out" "must be one of: install, remove, dry-run" "invalid action errors out"

out=$("$SCRIPT" --action dry-run --platform foo 2>&1 || true)
assert_contains "$out" "must be 'auto', 'cron', or 'launchd'" "invalid platform errors out"

out=$("$SCRIPT" --action dry-run --cadence "not a cron expr" --claude-path /usr/bin/claude 2>&1 || true)
assert_contains "$out" "must be 'weekly', 'monthly', or a 5-field cron expression" "invalid cadence errors out"

out=$("$SCRIPT" --help 2>&1)
assert_contains "$out" "Install or remove a recurring" "--help prints header"

# -----------------------------------------------------------------------------
# Dry-run (no writes)
# -----------------------------------------------------------------------------
H="$MOCK_DIR/home"
mkdir -p "$H/Library/LaunchAgents"

out=$(run_with_mocks "$H" --action dry-run --platform cron --claude-path /usr/bin/claude 2>&1)
assert_contains "$out" "Dry-run: would install rescue via cron" "dry-run cron header"
assert_contains "$out" "/impact-log rescue" "dry-run cron line includes subcommand"
assert_contains "$out" "Run with --action install to write." "dry-run prompts to install"

out=$(run_with_mocks "$H" --action dry-run --platform launchd --claude-path /usr/bin/claude 2>&1)
assert_contains "$out" "Dry-run: would install rescue via launchd" "dry-run launchd header"
assert_contains "$out" "net.spotify.sessions.impact-log.rescue" "dry-run launchd label"
assert_contains "$out" "$H/Library/LaunchAgents" "dry-run launchd plist path"

# Dry-run does not write to crontab / LaunchAgents
assert_eq "$(ls "$H/Library/LaunchAgents" | wc -l | tr -d ' ')" "0" "dry-run does not write plist"
[ ! -f "$MOCK_DIR/crontab.txt" ]
assert_eq "$?" "0" "dry-run does not write to crontab"

# -----------------------------------------------------------------------------
# Install / remove (cron)
# -----------------------------------------------------------------------------
reset_mocks
out=$(run_with_mocks "$H" --action install --platform cron --claude-path /usr/bin/claude 2>&1)
assert_contains "$out" "Installed (cron): /impact-log rescue" "cron install reports success"

[ -f "$MOCK_DIR/crontab.txt" ]
assert_eq "$?" "0" "cron install writes to crontab"

assert_contains "$(cat "$MOCK_DIR/crontab.txt")" "/impact-log rescue" "crontab contains the entry"

# Idempotency: second install errors out
out=$(run_with_mocks "$H" --action install --platform cron --claude-path /usr/bin/claude 2>&1 || true)
assert_contains "$out" "Already installed: /impact-log rescue" "second cron install rejected"

# Remove
out=$(run_with_mocks "$H" --action remove --platform cron 2>&1)
assert_contains "$out" "Removed (cron): /impact-log rescue" "cron remove reports success"
assert_not_contains "$(cat "$MOCK_DIR/crontab.txt")" "/impact-log rescue" "crontab no longer contains entry"

# Remove when nothing installed
out=$(run_with_mocks "$H" --action remove --platform cron 2>&1 || true)
assert_contains "$out" "No entry found for /impact-log rescue" "remove on missing entry errors out"

# -----------------------------------------------------------------------------
# Install / remove (launchd)
# -----------------------------------------------------------------------------
reset_mocks
rm -rf "$H/Library/LaunchAgents"
mkdir -p "$H/Library/LaunchAgents"

out=$(run_with_mocks "$H" --action install --platform launchd --claude-path /usr/bin/claude 2>&1)
assert_contains "$out" "Installed (launchd): net.spotify.sessions.impact-log.rescue" "launchd install reports success"

PLIST="$H/Library/LaunchAgents/net.spotify.sessions.impact-log.rescue.plist"
[ -f "$PLIST" ]
assert_eq "$?" "0" "launchd install writes plist"
assert_contains "$(cat "$PLIST")" "net.spotify.sessions.impact-log.rescue" "plist contains label"
assert_contains "$(cat "$PLIST")" "/impact-log rescue" "plist contains subcommand"

# Idempotency: second install errors out
out=$(run_with_mocks "$H" --action install --platform launchd --claude-path /usr/bin/claude 2>&1 || true)
assert_contains "$out" "Already installed: $PLIST" "second launchd install rejected"

# Remove
out=$(run_with_mocks "$H" --action remove --platform launchd 2>&1)
assert_contains "$out" "Removed (launchd): net.spotify.sessions.impact-log.rescue" "launchd remove reports success"
[ ! -f "$PLIST" ]
assert_eq "$?" "0" "launchd remove deletes plist"

# Remove when nothing installed
out=$(run_with_mocks "$H" --action remove --platform launchd 2>&1 || true)
assert_contains "$out" "No plist found at $PLIST" "remove on missing plist errors out"

# -----------------------------------------------------------------------------
# Custom subcommand label gets sanitized in launchd label
# -----------------------------------------------------------------------------
reset_mocks
out=$(run_with_mocks "$H" --action dry-run --platform launchd --subcommand "add --from quarterly" --claude-path /usr/bin/claude 2>&1)
assert_contains "$out" "net.spotify.sessions.impact-log.add---from-quarterly" "subcommand spaces become hyphens in launchd label"

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
TOTAL=$((PASS + FAIL))
echo
echo "Tests: $PASS passed, $FAIL failed (of $TOTAL)"
if [ "$FAIL" -gt 0 ]; then
  echo
  for detail in "${FAIL_DETAILS[@]}"; do
    echo "$detail"
    echo
  done
  exit 1
fi
