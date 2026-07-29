---
name: improving-test-coverage
description: Use when test coverage needs measuring or improving — after adding a feature or making significant changes, before a production deploy, when refactoring code that lacks tests, or when deciding which untested paths carry real risk. Triggers on "check coverage", "what isn't tested", "improve test coverage", "coverage report", and requests to set or enforce a coverage target.
---

# Code Coverage

Measure coverage, decide which gaps matter, and close the ones that do.

**Core principle:** Coverage measures which lines ran, not whether they work. Its real value is as a *map of untested risk* — use it to find code paths nobody thought about, not as a number to maximize.

## Workflow

```
- [ ] 1. Generate a baseline report
- [ ] 2. Triage the gaps by risk
- [ ] 3. Write tests for the gaps that matter
- [ ] 4. Verify the tests actually exercise the code
- [ ] 5. Set targets and enforce them in CI
```

### 1. Baseline

Use the project's existing coverage tool and test runner. If none is configured, pick the standard one for the language (`coverage`/pytest for Python, Jest or `nyc` for JS/TS, `go test -cover` for Go, JaCoCo for Java) and enable **branch coverage** — line coverage alone hides untested conditionals, which is where bugs live.

Configure exclusions before measuring: vendored code, generated files, migrations. A baseline polluted with third-party code tells you nothing.

Record overall percentage, uncovered line count, and the per-file distribution. Save it — step 4 compares against it.

### 2. Triage

This is the step that makes coverage work worth doing. For each gap, sort it into:

- **High-value** — core business logic and frequently used paths. Test these.
- **Edge cases** — error handling, boundaries, rare conditions. Usually worth testing; this is where coverage earns its keep, because these paths are untested precisely because nobody thought about them.
- **Dead code** — never executed. Don't test it. Delete it; removal is a legitimate coverage fix.
- **Infrastructure** — logging, config, bootstrapping. Low value; accept lower coverage here deliberately.

For each gap worth closing, note the risk if it fails and what it would take to test. Prioritize high-risk and cheap-to-test first.

```
src/services/user_service.py (82%, 8 uncovered lines)

L42-45  Password reset, email not found     risk HIGH   effort MED   → test now
L67-69  DB connection retry logic           risk MED    effort HIGH  → test later
L85     Logging on success path             risk LOW    effort LOW   → skip
```

### 3. Write the tests

Cover the normal case if it's missing, then the error and boundary cases specific to that path. Mock external dependencies at the boundary, not deep inside the logic you're trying to test.

### 4. Verify

Re-run coverage and compare against the baseline. Then verify test *quality*, which coverage cannot tell you:

- **Mutate the code and confirm the test fails.** A test that passes against broken code covers the line and verifies nothing. This is the single most valuable check in this skill.
- Run tests in isolation to catch inter-test dependencies.
- If coverage dropped, find out whether dead code was removed (fine) or new untested paths were added (not fine).

### 5. Targets and enforcement

Set differentiated targets rather than one global number — core logic ~95%, utilities ~80%, infrastructure ~60% — and write down *why*, plus what is intentionally not covered.

Enforce in CI with the tool's threshold flag (`--fail-under`, `check-coverage`) so the target is real rather than aspirational. Mark deliberate exclusions in code (`# pragma: no cover` or equivalent) so they're visible in review instead of showing up as unexplained gaps.

## Common mistakes

- **Chasing 100%.** Diminishing returns, and it pressures people into weak tests.
- **Coverage-bombing.** Many shallow tests raise the number and catch nothing. Few strong tests beat many weak ones.
- **Testing implementation instead of behavior.** Those tests break on every refactor and verify nothing about correctness.
- **Trusting the report over the code.** Read what the "covered" test actually asserts.
- **Ignoring hard-to-test code.** Difficulty is a design signal — refactor for testability rather than excluding it.

## Troubleshooting

**Code is tested but reported uncovered.** Confirm the test actually runs (break it deliberately and check it fails). Verify the tool's `source`/`include` paths. Dynamic dispatch, imports, and reflection often escape detection. Multi-process test runs need explicit coverage configuration — this is the most common cause with pytest-xdist.

**Tests pass but coverage reports 0%.** Almost always a config problem: source paths wrong, or the test runner overriding the coverage config. Run the coverage tool directly rather than through the runner.

**Coverage is low because of unreachable error handling.** Decide whether it's truly unreachable or merely rare. Rare gets a test with a mocked failure; truly unreachable gets deleted or marked with a documented pragma. Sometimes dependency injection is what makes the path testable at all.

**Coverage dropped after a refactor that passes tests.** The refactor likely added branches. Check for new conditionals and error paths, and confirm no dead code was introduced.

## Related skills

- **superpowers:test-driven-development** — write tests alongside code instead of retrofitting coverage
- **improving-code-reuse** — reduces the surface area needing coverage
