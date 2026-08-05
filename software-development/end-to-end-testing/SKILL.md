---
name: end-to-end-testing
description: Use when a user-facing feature, flow, endpoint, or integration point was added or changed; before committing when an E2E suite exists; when a project has unit tests but nothing exercising real user journeys; or when asked for end-to-end, system, acceptance, smoke, regression, or browser/API integration tests. Covers Playwright, Cypress, Selenium, pytest, and CLI/API suites.
---

# End-to-End Testing

## Overview

**Testing is the process of executing a program with the intent of finding errors** (Myers, *The Art of Software Testing*). A successful E2E test is one that **detects an undiscovered error**, not one that passes.

This reframing is the whole skill. A suite written to demonstrate the app works will be written to succeed, and will find nothing. A suite written to demonstrate the app fails its objectives finds real defects.

Unit tests ask "does this module match its interface spec?" E2E tests ask a different question the unit suite structurally cannot: **"does the assembled system do what its user reasonably expects — and does it avoid doing what it must not?"**

## When to Use

- After any major feature change, new endpoint, new user-facing flow, schema change, or integration with a third party
- Before committing to git, whenever an E2E suite exists (see Regression Discipline below — this is enforced by a hook)
- When a project has good unit coverage but no test drives the real, assembled system
- When a bug escaped to production despite green unit tests — that is a missing E2E case by definition

**Not for:** logic-level edge cases inside one module (use unit tests + `superpowers:test-driven-development`), throwaway prototypes, or generated code.

## Three Levels — Do Not Collapse Them

Most "E2E suites" are only the first row, which is why they miss the most expensive class of defect. Myers found the objectives→specification translation to be the *most error-prone step in the entire development cycle*.

| Level | Compares the system to… | Derived from | Finds |
|---|---|---|---|
| **Function** | its external specification | the spec / API docs / UI contract | "the feature is wrong" |
| **System** | its original objectives | README, product goals, user documentation — **never the spec or the code** | "we built the wrong feature" |
| **Acceptance** | current user needs | real user journeys, support tickets | "nobody can actually use this" |

**Rule with teeth:** derive system-level cases from the objectives and the user-facing documentation, never by reading the implementation. Cases derived from the code can only confirm the code. If the documentation and the objectives disagree, you have found a defect before writing a line of test.

## Contract: What Every E2E Test Must Contain

Write each test so it has these six parts, in this order. A file that has all six is done; one that is missing a part is not an E2E test yet.

1. **A name stating the user-visible outcome.** `checkout with an expired card is rejected and no order is created` — not `test checkout 2`.
2. **A known starting state**, established by setup and torn down after. Tests must be re-runnable in any order, on a dirty machine.
3. **The real assembled system.** Real HTTP, real database, real navigation. Mock only what you cannot own (payment processors, SMS gateways) and mock it at the network boundary, never by stubbing your own tiers.
4. **The expected result, written before the test is run.** Myers: defining the expected output is part of the test case, not a thing you read off the first run. A test whose assertion was copied from actual output asserts nothing.
5. **At least one invalid or unexpected input per journey.** Empty, zero, absent, one-too-many, wrong type, wrong order, hostile. These have a *higher* defect yield than valid inputs.
6. **A negative assertion — what must NOT have happened.** No duplicate order row, no email sent, no partial write, no error in the console, no unauthorized record visible. Half of testing is checking the program does not do what it is not supposed to do.

Item 6 is the one that gets dropped. A payroll program that prints correct paychecks is still broken if it also prints checks for nonexistent employees, and no positive assertion will ever catch that.

## Designing the Cases

Apply in this order — each contributes cases the others miss:

1. **Cause-effect** — if the flow has combinations of conditions (logged in × cart non-empty × coupon valid), enumerate the combinations first.
2. **Boundary value analysis** — highest payoff per case. Test on, above, and below every edge, of **inputs and of outputs**.
3. **Equivalence partitioning** — one representative per valid class; each invalid class gets its own test, alone, because one rejection masks another.
4. **Error guessing** — enumerate what a developer plausibly forgot: empty list, single item, already-sorted, duplicate names, concurrent submit, back button, double-click, expired session, 4-byte emoji.
5. **Coverage check** — did the journeys actually exercise the paths you care about? Fill gaps.

Full recipes and worked examples: `references/test-case-design.md`.

## Coverage: The 15 System-Test Categories

Facility, volume, stress, usability, security, performance, storage, configuration, compatibility/conversion, installation, reliability, recovery, serviceability, documentation, procedure.

Not all 15 apply to every project, but **walk the whole list every time** — the point is to avoid silently omitting an entire class of defect. Full descriptions, modern web/API/CLI translations, and per-tier checklists: `references/system-test-categories.md`.

## Regression Discipline

Changes and bug fixes are **more error-prone than the original code** — same reason most newspaper typos are in last-minute edits. This makes regression runs non-negotiable.

```
NEVER COMMIT WITHOUT RUNNING THE E2E SUITE FIRST
```

Also: **never write a throwaway test.** Every case you exercise by hand in a terminal or a browser is an investment that evaporates. Encode it in the suite or you will re-invent it — badly, and less rigorously — after the next change.

| Rationalization | Reality |
|---|---|
| "The change was tiny / config only" | Config and one-line changes are exactly where regressions hide. Run it. |
| "Unit tests are green" | Unit tests passed for every bug that ever reached production. Different question, different suite. |
| "The suite is slow" | Slower than a production incident? Fix the suite's speed as its own task; do not skip the run. |
| "I only touched the frontend" | E2E exists precisely because tier boundaries lie. Run it. |
| "I ran it ten minutes ago" | Did you edit anything since? Then that run tested different code. |
| "I'll run it right after committing" | The commit is the artifact others pull. Run before. |
| "It's failing for an unrelated reason" | Then you have two defects. Fix or explicitly quarantine with the user's agreement — do not step over. |
| "The user is in a hurry" | Say the suite is running and how long it takes. That is faster than shipping the regression. |

**Red flags — stop and run the suite:**
- About to run `git commit` and you cannot name the last suite result
- About to use `--no-verify` or set a skip variable
- Editing a test's assertion so it matches new actual output → invoke `tdd-test-change-approval` first
- Deleting or `.skip`-ing a failing E2E test to unblock a commit

**Reporting the result is part of the run.** State the pass/fail counts you actually saw. Never claim the suite passes without the output in front of you — `superpowers:verification-before-completion`.

## Completion Criteria

"All tests pass" is a **counterproductive** stopping rule. It is satisfiable by writing weak tests, and it subconsciously steers you toward cases that cannot fail.

Stop when all three hold:

- The design techniques above were applied to each changed journey (not just the happy path)
- The 15 categories were walked and the inapplicable ones consciously dismissed
- The defect-discovery rate has flattened — you are writing new cases and no longer finding anything

Corollary (Myers' clustering principle): **the probability of more defects in an area is proportional to the number already found there.** When one journey yields three bugs, spend your next hour there, not spread evenly across the suite.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Suite is all happy paths | Every journey gets an invalid-input case and a negative assertion |
| Assertions copied from actual output | Write the expected result before the first run |
| Mocking your own database/API tier | Mock only third parties, at the network boundary |
| Tests share state and must run in order | Independent setup/teardown per test |
| Flaky waits (`sleep 2000`) | Wait on an observable condition, not a duration |
| Only checking the response the test asked for | Inspect all results — logs, side tables, emails, console errors |
| Writing tests by reading the implementation | Derive from objectives and user documentation |
| One giant "full journey" test | One journey per test; a failure must localize |
