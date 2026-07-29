#!/usr/bin/env bash
# test_validate_placeholders.sh — Verify placeholder validation logic.
# Run from the skill root: ./tests/test_validate_placeholders.sh
set -euo pipefail

SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/scripts/validate_placeholders.sh"
TESTROOT="$PWD/tmp_test_placeholders"
PASSED=0
FAILED=0

pass() {
	PASSED=$((PASSED + 1))
	echo "  PASS: $1"
}
fail() {
	FAILED=$((FAILED + 1))
	echo "  FAIL: $1"
}

cleanup() { rm -rf "$TESTROOT"; }
trap cleanup EXIT

echo "=== validate_placeholders.sh test suite ==="

# Test 1: Clean directory (no placeholders)
TD="$TESTROOT/test_clean"
mkdir -p "$TD"
printf '%s\n' '\documentclass{article}' '\begin{document}' 'Email: test@example.com' 'Phone: 555-0100' '\end{document}' >"$TD/clean.tex"

if "$SCRIPT" "$TD" >/dev/null 2>&1; then
	pass "Test 1 — Clean .tex files exit code 0"
else
	fail "Test 1 — Clean .tex should exit 0, got non-zero"
fi

# Test 2: One unfilled placeholder
TD="$TESTROOT/test_missing"
mkdir -p "$TD"
printf '%s\n' '\documentclass{article}' '\begin{document}' '[EMAIL]' 'Phone: 555-0100' '\end{document}' >"$TD/incomplete.tex"

if ! "$SCRIPT" "$TD" >/dev/null 2>&1; then
	pass "Test 2 — Missing placeholder exits non-zero"
else
	fail "Test 2 — Should exit non-zero for missing [EMAIL]"
fi

# Test 3: Multiple unfilled placeholders reported
TD="$TESTROOT/test_multi"
mkdir -p "$TD"
printf '%s\n' '[EMAIL]' '[PHONE]' 'COMPANY: Acme Corp' >"$TD/multi.tex"

OUTPUT=$("$SCRIPT" "$TD" 2>&1) || true
if echo "$OUTPUT" | grep -q 'VALIDATION FAILED'; then
	pass "Test 3 — Multiple missing placeholders reported as FAILED"
else
	fail "Test 3 — Should report VALIDATION FAILED with multiple issues"
fi

# Test 4: Non-existent directory
if ! "$SCRIPT" "/nonexistent/path" >/dev/null 2>&1; then
	pass "Test 4 — Non-existent directory exits non-zero"
else
	fail "Test 4 — Should exit non-zero for bad directory"
fi

# Test 5: All placeholder types detected
TD="$TESTROOT/test_all_types"
mkdir -p "$TD"
cat >"$TD/all.tex" <<'TEXEOF'
\documentclass{article}
[EMAIL][PHONE][LINKEDIN_URL][LINKEDIN_USERNAME]
[GITHUB_URL][GITHUB_USERNAME][WEBSITE_URL][WEBSITE_NAME]
[COMPANY_NAME][LOCATION][Position Title]
TEXEOF

OUTPUT=$("$SCRIPT" "$TD" 2>&1) || true
if echo "$OUTPUT" | grep -q 'VALIDATION FAILED'; then
	COUNT=$(echo "$OUTPUT" | grep -c '\bMISSING\b' || true)
	if [[ $COUNT -ge 8 ]]; then
		pass "Test 5 — All placeholder types detected ($COUNT issues found)"
	else
		fail "Test 5 — Expected 8+ MISSING entries, got $COUNT"
	fi
else
	fail "Test 5 — Should report VALIDATION FAILED"
fi

# Test 6: Non-.tex files with placeholders are ignored
TD="$TESTROOT/test_no_tex"
mkdir -p "$TD"
printf '%s\n' '[EMAIL]' >"$TD/readme.md"
cat >"$TD/clean.tex" <<'TEXEOF'
\documentclass{article}
Everything fine here.
TEXEOF

if "$SCRIPT" "$TD" >/dev/null 2>&1; then
	pass "Test 6 — Non-.tex file placeholders ignored, only .tex checked"
else
	fail "Test 6 — .md file placeholders should be ignored"
fi

# Test 7: Empty directory (no .tex files)
TD="$TESTROOT/test_empty"
mkdir -p "$TD"

if "$SCRIPT" "$TD" >/dev/null 2>&1; then
	pass "Test 7 — Empty directory exits clean (0 tex files)"
else
	fail "Test 7 — Empty dir should exit 0, no tex files to scan"
fi

# Summary
echo ""
TOTAL=$((PASSED + FAILED))
echo "Results: $PASSED passed, $FAILED failed out of $TOTAL tests"

if [[ $FAILED -gt 0 ]]; then
	echo ""
	echo "*** SOME TESTS FAILED ***"
	exit 1
else
	echo "All tests passed!"
	exit 0
fi
