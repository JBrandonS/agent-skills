#!/usr/bin/env bash
# PreToolUse(Bash) gate: run the project's E2E suite before any `git commit`.
#
# Blocks the commit (exit 2) if the suite fails. If no E2E suite can be detected,
# emits a non-blocking nudge toward the end-to-end-testing skill.
#
# Escape hatch: export CLAUDE_SKIP_E2E=1
#
# Project override: put the exact command in <repo>/.claude/e2e-command (one line).

set -uo pipefail

payload=$(cat)

cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // ""' 2>/dev/null)
cwd=$(printf '%s' "$payload" | jq -r '.cwd // ""' 2>/dev/null)
[ -n "$cwd" ] && [ -d "$cwd" ] || cwd=$PWD

# Only interested in real commits.
printf '%s' "$cmd" | grep -Eq '(^|[;&|[:space:]])git[[:space:]]+([^;&|]*[[:space:]])?commit([[:space:]]|$)' || exit 0
# Not a real commit if it's a dry run, or just reading history.
printf '%s' "$cmd" | grep -Eq '(--dry-run|--help|-h$)' && exit 0

[ "${CLAUDE_SKIP_E2E:-0}" = "1" ] && exit 0

root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null) || exit 0

nudge() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":%s}}\n' \
    "$(printf '%s' "$1" | jq -Rs .)"
  exit 0
}

pm() { # pick a package runner that exists
  if [ -f "$root/bun.lockb" ] || [ -f "$root/bun.lock" ]; then echo "bun run"
  elif [ -f "$root/pnpm-lock.yaml" ]; then echo "pnpm run"
  elif [ -f "$root/yarn.lock" ]; then echo "yarn"
  else echo "npm run"
  fi
}

# ---- detect the E2E command -------------------------------------------------
e2e=""
label=""

if [ -r "$root/.claude/e2e-command" ]; then
  e2e=$(grep -v '^[[:space:]]*#' "$root/.claude/e2e-command" | grep -v '^[[:space:]]*$' | head -1)
  label=".claude/e2e-command"
fi

if [ -z "$e2e" ] && [ -r "$root/package.json" ] && command -v jq >/dev/null 2>&1; then
  for s in test:e2e e2e test:integration; do
    if jq -e --arg s "$s" '.scripts[$s] // empty' "$root/package.json" >/dev/null 2>&1; then
      e2e="$(pm) $s"; label="package.json script \"$s\""; break
    fi
  done
fi

if [ -z "$e2e" ]; then
  if compgen -G "$root/playwright.config.*" >/dev/null; then
    e2e="npx --no-install playwright test"; label="playwright.config"
  elif compgen -G "$root/cypress.config.*" >/dev/null; then
    e2e="npx --no-install cypress run"; label="cypress.config"
  elif [ -d "$root/tests/e2e" ] && compgen -G "$root/tests/e2e/*.py" >/dev/null; then
    e2e="python -m pytest tests/e2e -q"; label="tests/e2e (pytest)"
  elif [ -d "$root/e2e" ] && compgen -G "$root/e2e/*_test.go" >/dev/null; then
    e2e="go test ./e2e/..."; label="e2e (go test)"
  elif [ -f "$root/Makefile" ] && grep -Eq '^(test-e2e|e2e):' "$root/Makefile"; then
    target=$(grep -Eo '^(test-e2e|e2e):' "$root/Makefile" | head -1 | tr -d ':')
    e2e="make $target"; label="Makefile target \"$target\""
  fi
fi

if [ -z "$e2e" ]; then
  nudge "No E2E suite was detected in $root (looked for .claude/e2e-command, a package.json test:e2e/e2e script, playwright/cypress config, tests/e2e, e2e/*_test.go, or a Makefile e2e target).

This commit is NOT blocked. But if this change touched a user-facing feature, flow, endpoint, or integration point, the end-to-end-testing skill applies: an E2E suite should exist and should have been run. Tell the user plainly that no E2E suite is configured rather than silently committing, and offer to create one. Once a suite exists, record its command in .claude/e2e-command so this gate can enforce it."
fi

# ---- run it -----------------------------------------------------------------
out=$(cd "$root" && eval "$e2e" 2>&1)
status=$?

if [ $status -ne 0 ]; then
  tail_out=$(printf '%s' "$out" | tail -n 60)
  cat >&2 <<EOF
COMMIT BLOCKED — the E2E suite failed.

  command: $e2e   (from $label)
  cwd:     $root
  exit:    $status

--- last 60 lines ---
$tail_out
---------------------

Do not commit. Do not retry with --no-verify or CLAUDE_SKIP_E2E. Fix the failure, or
— if the failure is genuinely unrelated to this change — stop and tell the user what
is failing and why, and let them decide. Editing or skipping a test to get past this
gate requires explicit approval (see the tdd-test-change-approval skill).
EOF
  exit 2
fi

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":%s}}\n' \
  "$(printf 'E2E suite passed before commit (%s, from %s).' "$e2e" "$label" | jq -Rs .)"
exit 0
