#!/usr/bin/env bash
# test_generate-schedule-entry.sh — Unit tests for generate-schedule-entry.sh
#
# Tests argument parsing, cadence resolution, platform selection, cron line
# generation, and launchd plist generation — all without modifying any
# real cron / launchd state.
#
# Usage: bash test_generate-schedule-entry.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_UNDER_TEST="$SCRIPT_DIR/generate-schedule-entry.sh"

# Stub claude path so tests are platform-independent and don't require claude installed.
STUB_CLAUDE="/usr/local/bin/claude"

# -----------------------------------------------------------------------------
# Test framework (matches test_install-skills-globally.sh / test_gworkspace_*)
# -----------------------------------------------------------------------------
PASS=0
FAIL=0
ERRORS=""

assert_eq() {
  local test_name="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    PASS=$((PASS + 1))
    echo "  PASS: $test_name"
  else
    FAIL=$((FAIL + 1))
    ERRORS="${ERRORS}\n  FAIL: $test_name\n    Expected: $expected\n    Actual:   $actual"
    echo "  FAIL: $test_name"
    echo "    Expected: $expected"
    echo "    Actual:   $actual"
  fi
}

assert_contains() {
  local test_name="$1" expected_substr="$2" actual="$3"
  if echo "$actual" | grep -qF -- "$expected_substr"; then
    PASS=$((PASS + 1))
    echo "  PASS: $test_name"
  else
    FAIL=$((FAIL + 1))
    ERRORS="${ERRORS}\n  FAIL: $test_name\n    Expected to contain: $expected_substr\n    Actual: $actual"
    echo "  FAIL: $test_name"
    echo "    Expected to contain: $expected_substr"
    echo "    Actual: $actual"
  fi
}

assert_not_contains() {
  local test_name="$1" forbidden_substr="$2" actual="$3"
  if echo "$actual" | grep -qF -- "$forbidden_substr"; then
    FAIL=$((FAIL + 1))
    ERRORS="${ERRORS}\n  FAIL: $test_name\n    Should NOT contain: $forbidden_substr\n    Actual: $actual"
    echo "  FAIL: $test_name"
    echo "    Should NOT contain: $forbidden_substr"
  else
    PASS=$((PASS + 1))
    echo "  PASS: $test_name"
  fi
}

# Helper to run the script with a given platform forced
run_with() {
  bash "$SCRIPT_UNDER_TEST" --claude-path "$STUB_CLAUDE" "$@" 2>&1
}

# -----------------------------------------------------------------------------
# Test 1: defaults (cron platform, weekly, rescue)
# -----------------------------------------------------------------------------
echo "Test 1: defaults force-platform cron"
OUT=$(run_with --platform cron)
assert_contains "1.1 default subcommand is rescue" "/impact-log rescue" "$OUT"
assert_contains "1.2 default cadence is weekly (0 9 * * 1)" "0 9 * * 1" "$OUT"
assert_contains "1.3 cron output identifies as cron entry" "(cron)" "$OUT"
assert_contains "1.4 install instructions reference crontab" "crontab -e" "$OUT"
assert_contains "1.5 remove instructions present" "Remove later" "$OUT"
assert_contains "1.6 log path documented" ".claude/impact-log-schedule.log" "$OUT"
assert_contains "1.7 stub claude path used" "$STUB_CLAUDE" "$OUT"

echo ""
echo "Test 2: --cadence monthly"
OUT=$(run_with --platform cron --cadence monthly)
assert_contains "2.1 monthly produces 1st-of-month cron expr" "0 9 1 * *" "$OUT"

echo ""
echo "Test 3: --cadence with literal cron expression"
OUT=$(run_with --platform cron --cadence "30 14 * * 5")
assert_contains "3.1 literal cron expression preserved" "30 14 * * 5" "$OUT"

echo ""
echo "Test 4: invalid cadence (wrong field count)"
set +e
OUT=$(run_with --platform cron --cadence "0 9 *" 2>&1)
RC=$?
set -e
assert_eq "4.1 invalid cadence exits non-zero" "2" "$RC"
assert_contains "4.2 invalid cadence error message" "5-field cron expression" "$OUT"

echo ""
echo "Test 5: --subcommand override"
OUT=$(run_with --platform cron --subcommand "add --from quarterly")
assert_contains "5.1 custom subcommand appears in output" "/impact-log add --from quarterly" "$OUT"

echo ""
echo "Test 6: launchd platform"
OUT=$(run_with --platform launchd --cadence weekly)
assert_contains "6.1 launchd output identifies as launchd entry" "(launchd)" "$OUT"
assert_contains "6.2 launchd plist DOCTYPE present" "<!DOCTYPE plist" "$OUT"
assert_contains "6.3 launchd Label uses spotify namespace" "net.spotify.sessions.impact-log" "$OUT"
assert_contains "6.4 launchd weekly maps Hour=9" "<integer>9</integer>" "$OUT"
assert_contains "6.5 launchd weekly maps Weekday=1" "<key>Weekday</key>" "$OUT"
assert_contains "6.6 launchd install uses launchctl load" "launchctl load" "$OUT"
assert_contains "6.7 launchd remove uses launchctl unload" "launchctl unload" "$OUT"
assert_not_contains "6.8 launchd output does NOT include crontab instructions" "crontab -e" "$OUT"

echo ""
echo "Test 7: launchd label sanitization (subcommand with spaces)"
OUT=$(run_with --platform launchd --subcommand "add --from quarterly")
assert_contains "7.1 spaces in subcommand replaced with hyphens in label" "net.spotify.sessions.impact-log.add---from-quarterly" "$OUT"

echo ""
echo "Test 8: launchd monthly omits Weekday, includes Day"
OUT=$(run_with --platform launchd --cadence monthly)
assert_contains "8.1 monthly includes Day key" "<key>Day</key>" "$OUT"
assert_not_contains "8.2 monthly omits Weekday key" "<key>Weekday</key>" "$OUT"

echo ""
echo "Test 8b: launchd plist log paths are absolute (no literal \$HOME)"
# Regression test for Gosling-flagged bug: launchd does not expand env-vars in
# plist string values. StandardOutPath / StandardErrorPath must be absolute.
OUT=$(run_with --platform launchd)
# Extract the StandardOutPath / StandardErrorPath values from the plist
STDOUT_LINE=$(echo "$OUT" | grep -A 1 'StandardOutPath' | grep '<string>' | head -1)
STDERR_LINE=$(echo "$OUT" | grep -A 1 'StandardErrorPath' | grep '<string>' | head -1)
assert_not_contains "8b.1 launchd StandardOutPath has no literal \$HOME" '$HOME' "$STDOUT_LINE"
assert_not_contains "8b.2 launchd StandardErrorPath has no literal \$HOME" '$HOME' "$STDERR_LINE"
assert_contains "8b.3 launchd StandardOutPath starts with /" "<string>/" "$STDOUT_LINE"
assert_contains "8b.4 launchd StandardErrorPath starts with /" "<string>/" "$STDERR_LINE"
assert_contains "8b.5 launchd plist references resolved log path" ".claude/impact-log-schedule.log" "$OUT"

echo ""
echo "Test 8c: cron crontab line keeps literal \$HOME (cron's shell expands it)"
OUT=$(run_with --platform cron)
assert_contains "8c.1 cron output contains literal \$HOME in crontab line" '$HOME/.claude/impact-log-schedule.log' "$OUT"

echo ""
echo "Test 9: invalid platform"
set +e
OUT=$(run_with --platform bogus 2>&1)
RC=$?
set -e
assert_eq "9.1 invalid platform exits non-zero" "2" "$RC"
assert_contains "9.2 invalid platform error message" "must be 'auto', 'cron', or 'launchd'" "$OUT"

echo ""
echo "Test 10: unknown flag"
set +e
OUT=$(run_with --bogus-flag 2>&1)
RC=$?
set -e
assert_eq "10.1 unknown flag exits with code 2" "2" "$RC"
assert_contains "10.2 unknown flag error message" "Unknown option" "$OUT"

echo ""
echo "Test 11: missing claude binary (no --claude-path, claude not in PATH)"
# Use a path with standard utilities (awk, uname, etc.) but reliably without claude.
# /usr/bin and /bin are the standard system locations; claude typically lives in
# /usr/local/bin or ~/.claude/local, not /usr/bin.
TEST_PATH="/usr/bin:/bin"
if command -v claude >/dev/null 2>&1 && [ "$(dirname "$(command -v claude)")" = "/usr/bin" ]; then
  echo "  SKIP: claude is in /usr/bin on this machine; cannot run this test cleanly"
else
  set +e
  OUT=$(PATH="$TEST_PATH" bash "$SCRIPT_UNDER_TEST" --platform cron 2>&1)
  RC=$?
  set -e
  assert_eq "11.1 missing claude exits with code 1" "1" "$RC"
  assert_contains "11.2 missing claude error message" "claude" "$OUT"
fi

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo ""
echo "================================================================"
echo "Tests: $((PASS + FAIL))  Passed: $PASS  Failed: $FAIL"
echo "================================================================"
if [ "$FAIL" -gt 0 ]; then
  echo -e "$ERRORS"
  exit 1
fi
exit 0
