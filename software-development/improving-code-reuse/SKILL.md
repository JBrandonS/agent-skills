---
name: improving-code-reuse
description: Use when code has duplication or reuse problems — the same fix keeps being applied in several places, copy-pasted blocks have spread across modules, components can't be reused without editing them, God classes have accumulated, or duplication metrics are high. Triggers on "make this more reusable", "refactor for reuse", "is this DRY?", "find duplicate code", "deduplicate", "code duplication", and "reusability report". Extraction work is risky and token-heavy, so confirm before refactoring.
---

# Improving Code Reuse

Find duplicated and unreusable code, then either report on it or consolidate it.

**Core principle:** Detection is mechanical; the decision to consolidate is not. Tools find code that *looks* the same — you decide whether it *means* the same. Most bad refactoring comes from skipping that judgment.

## Step 1: Pick a mode

| User language | Mode |
|---|---|
| "check", "review", "audit", "what's wrong", "report", "analyze" | `report` — findings only, no edits |
| "fix", "refactor", "clean up", "deduplicate", "improve" | `refactor` — apply changes |

If ambiguous, ask. Before entering `refactor` mode, confirm the prerequisites below — extraction without them is how this work introduces bugs.

**Refactor prerequisites:**
- **A git worktree or branch.** Never refactor directly on main.
- **Existing tests.** Refactoring untested code has no safety net. Add coverage first (see **superpowers:test-driven-development**).

## Step 2: Detect

Two complementary passes. Run both — they find different things.

**Mechanical.** jscpd finds textual duplication:

```bash
npx jscpd --reporters json --reporters html --min-lines 3 --min-tokens 30 \
  --exclude "node_modules,dist,build,.git" .
```

Start at 3–5 lines. Higher thresholds cut noise but hide small, high-churn duplicates. Discard hits in generated code, vendored files, and test fixtures. Sort each hit into **exact** (extract directly), **parameterized** (same logic, varying values), or **structural** (same workflow, different modules).

**Judgment.** jscpd can't see these, so read for them directly:

- **DRY** — the same algorithm under different names; magic values repeated instead of named; repeated error-handling, retry, or transformation patterns
- **KISS** — functions doing more than one thing; abstractions whose indirection costs more than the duplication they remove
- **SOLID** — one reason to change per unit; extension without modification; substitutable subtypes; focused interfaces; dependencies on abstractions
- **Modularity** — cohesive units, loose coupling, clear boundaries between data / logic / presentation
- **Component design** — inheritance used for "is-a" and not as a code-sharing shortcut; UI components parameterized rather than forked

Note where you can estimate them: duplication rate, proportion of functions called from more than one site, and any unit over ~200 lines or carrying more than a handful of responsibilities.

## Step 3: Triage

The step that makes this work worth doing. For every candidate, before touching code:

- **Why does this duplication exist?** Oversight and copy-paste are consolidation candidates. Independent development for different domains usually isn't.
- **Are these the same, or just shaped the same?** Different business rules frequently produce identical structure. Similar shape is not shared meaning — this is the most common false positive.
- **Will these change together?** If a future requirement would change one copy but not the other, consolidating creates a conditional-riddled shared function that is worse than the duplication.

**Leave alone:** domain logic that only looks similar, hot paths where indirection has measured cost, platform- or environment-specific code, and code too new to have stabilized.

Record for each group: root cause, proposed abstraction, risk (low/medium/high), and expected savings.

## Step 4a: Report mode

```
## Code Reuse Report

### Summary
[1-2 sentences: overall assessment and the single biggest issue.]

### Findings

#### 🔴 Critical
[Each: location (file, function, lines) · problem · proposed abstraction · risk]

#### 🟡 Warnings
[Same format.]

#### 🟢 Done well
[What's already solid — keeps the picture balanced and prevents needless churn.]

### Deliberately not consolidated
[Groups that looked like duplicates but shouldn't be merged, and why.]

### Recommended actions
[Prioritized, concrete, highest-impact first.]

### Metrics
- Duplication rate: ~X%
- Units needing simplification: [list]
- Refactor effort: low / medium / high
```

## Step 4b: Refactor mode

Apply in this order — each step makes the next easier to see:

1. **Extract duplicates** — pick the smallest abstraction that covers the group: a function, then a utility module, then a shared class, then a higher-order function. Copy the *cleanest* duplicate as the base, parameterize the points of variation, update every caller, delete the copies.
2. **SOLID** — split multi-responsibility units; introduce abstractions where concretions are hardcoded.
3. **KISS** — remove needless complexity; inline over-abstracted helpers; clarify naming.
4. **Modularity** — reorganize into cohesive units where structure allows.
5. **Patterns** — only where they genuinely simplify.

The failure mode to watch for: parameterizing so many axes that the shared function is harder to read than the duplicates were. If you're adding a third boolean flag, the group was mis-triaged — back out and leave the copies.

```typescript
// Two fetchers differing only in endpoint and log text
export function fetchResource(endpoint: string) {
  return fetch(endpoint)
    .then(r => r.json())
    .catch(err => { console.error(`Fetch from ${endpoint} failed`, err); throw err; });
}

const user = await fetchResource(`/api/users/${id}`);
```

Note the rethrow: the original copies swallowed the error and returned `undefined`. Consolidation is the moment to fix a bug shared by every copy — but do it as a separate, called-out change, never silently folded into the extraction.

Generalize only after a pattern appears a third time.

## Step 5: Test

Run the full suite after **each** extraction, not once at the end — that's what makes a failure attributable.

Beyond "tests pass": exercise the shared implementation with inputs from every original call site. Copies drift, and the edge case handled in only one of them is exactly what a shared function loses. Collapse the now-duplicated tests into one suite for the shared code.

## Step 6: Document

In the shared module, record what it's for and what constraints apply. In the code you *didn't* consolidate, leave a comment saying why — otherwise the next person redoes this analysis, or worse, consolidates it.

Close with a change summary grouped by the step-4b categories, plus trade-offs made and follow-ups.

## Scope

- **Single file or snippet** — analyze fully.
- **Multiple files** — prioritize the most impactful; state explicitly which files you did not review.
- **Too large for one pass** — report first, then ask which areas to refactor.

## Common mistakes

- **Consolidating similar-looking code with different meaning.** Ask why the duplication exists before removing it.
- **Consolidating before divergence settles.** Wait for the code to stabilize.
- **Extracting code you don't fully understand.** Subtle behavior differences between copies become silent bugs.
- **Reporting principle names instead of locations.** "Violates SRP" is not actionable; "`UserService` handles auth, email, and billing — split at these three boundaries" is.
- **Breaking the public API without deprecation.** External consumers shouldn't need changes.
- **One giant commit.** Batch by component so review and rollback stay possible.

## Troubleshooting

**jscpd reports framework boilerplate as duplicates.** Raise thresholds and exclude patterns in a jscpd config: `{"ignore": ["node_modules", "dist", "**/*.d.ts"], "minLines": 5, "minTokens": 50}`.

**Refactoring broke something unexpectedly.** Extract one function at a time and test between each. Compare original and refactored behavior on identical inputs, and check for side effects or state mutation in the extracted code.

**The extracted code is too generic to understand.** The consolidation probably wasn't worth it. Either add domain-specific wrappers over the generic core, or revert and keep the copies.

## Related skills

- **superpowers:test-driven-development** — build the safety net before refactoring
- **compacting-codebases** — when the goal is reducing codebase size for AI ingestion
- **improving-test-coverage** — establish coverage before a risky extraction
