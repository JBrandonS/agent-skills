---
name: compacting-codebases
description: Use when a codebase is too large for an AI agent to ingest within its context window, when files have grown past a few hundred lines each, or when the user asks to shrink the codebase without changing behavior. Triggers on "compact this", "reduce code size", "shrink the codebase", "make it more token-efficient", and "optimize for AI ingestion".
---

# Code Compaction

Reduce a codebase's size — fewer lines, smaller files — without changing behavior, so agents can ingest it within a context window.

**Core principle:** Compaction removes waste, not clarity. Every change must be behavior-preserving and verified by tests; if you can't verify it, don't make it.

## Prerequisites

- **A git branch.** Never compact on main without a way back.
- **A passing test suite.** Compacting untested code is guesswork. If none exists, write characterization tests first (**superpowers:test-driven-development**).

## Workflow

Ordered by risk, lowest first. Test after every step.

```
- [ ] 0. Measure the baseline
- [ ] 1. Reorder and remove dead code
- [ ] 2. Deduplicate
- [ ] 3. Split oversized files
- [ ] 4. Share behavior via inheritance or composition
- [ ] 5. Replace verbose code with language idioms
- [ ] 6. Verify coverage against baseline
```

### 0. Measure

```bash
# Largest files, excluding build output
fd -e py -e ts -e js -E node_modules -E dist -E build | xargs wc -l | sort -rn | head -20

# Duplication
npx jscpd --reporters json --min-lines 3 --min-tokens 30 .
```

Record total LOC, file count, largest files, and duplication percentage. Without a baseline you can't tell compaction from churn.

### 1. Reorder and remove dead code

Lowest-risk step. Sort imports (`isort`, `eslint --fix`), drop unused ones (`pyflakes` or `ruff` for Python), and delete unreachable functions, unused parameters, and commented-out blocks.

Reorder within files to the language's convention — top-down, abstractions before details. Merge a file only when it holds one or two trivial functions used by a single consumer.

Do not change behavior in this step. Only move and delete.

### 2. Deduplicate

Highest-impact step. Follow the **improving-code-reuse** skill's refactor workflow, prioritizing duplicates inside the largest files — those give the most LOC back per change.

### 3. Split oversized files

Splitting raises file count but cuts per-file token load, which is what actually matters for ingestion.

Split files over ~500 lines that carry multiple distinct responsibilities. Cut along real boundaries — separate domains, data versus behavior, validation versus processing versus output — never at an arbitrary line count. Preserve the public API with re-exports from the package's `__init__.py` or index file, then update internal imports.

Leave cohesive files under ~100 lines alone. Re-run duplicate detection afterward: splitting frequently exposes cross-file duplication that was invisible before.

### 4. Share behavior

Pull identical methods across classes into a base class when there's a real "is-a" relationship and shared implementation; use composition or a mixin when the behavior is interchangeable but the identity isn't.

Constraints: prefer composition, keep hierarchies under three levels, and make each level add real behavior rather than passing through. A base class that exists purely to save a method is a net loss — it costs a file, an import, and a lookup.

### 5. Language idioms

Replace verbose constructions with the language's built-in equivalents: comprehensions for accumulate-loops, `defaultdict` for manual dict-of-list building, `Enum` for constant classes, f-strings for concatenation, optional chaining and nullish coalescing for null-check chains, destructuring for repeated property access, dispatch tables for long if-else chains.

Two rules: the replacement must behave identically at the edges (`or` and `??` differ on falsy-but-valid values like `0` and `""` — this is the most common bug introduced in this step), and clever one-liners that hurt readability are not compaction, they're obfuscation.

### 6. Verify

Run the full suite after each step, and coverage against the baseline at the end.

Coverage dropping means one of two things: tested code was removed (good — it was dead) or untested code broke (bad). Find out which by looking at the specific lines.

```
Compaction Results:
- Before: X LOC, Y files, N% duplication
- After:  Z LOC, W files, M% duplication
- Coverage: before → after (must not regress)
- Tests: all passing
```

## Targets

| Metric | Target | Notes |
|--------|--------|-------|
| LOC reduction | 10–30% | Heavily duplicated code can exceed 50% |
| Largest file | <500 lines | The number that most affects ingestion |
| Duplication rate | <5% | From jscpd |
| Coverage | ≥ baseline | Never trade coverage for size |

## Common mistakes

- **Compacting untested code.** The whole method depends on the test suite catching behavior changes.
- **Trading readability for line count.** Clarity beats brevity; a compact codebase nobody can read is worse for agents too.
- **Large batches.** One change at a time, tests between each — otherwise a failure isn't attributable.
- **Splitting cohesive files.** More files with tangled imports is worse than one coherent file.

## Troubleshooting

**Compaction broke behavior.** Undo immediately, then add a regression test that captures the behavior before retrying.

**Deduplication produced a fragile abstraction.** Not all duplicates should be consolidated — see the triage step of the **improving-code-reuse** skill. Revert and leave the copies.

**File splitting broke imports.** Add re-exports in the package's entry file for backward compatibility, then migrate internal imports gradually.

**The agent still runs out of context.** Compaction alone may not be enough. Add a `CONTEXT.md` summarizing the architecture, or scope the agent's work per-file rather than loading the whole codebase.

## Related skills

- **improving-code-reuse** — the highest-impact compaction step; run its full workflow at step 2
- **superpowers:test-driven-development** — the safety net every step depends on
- **improving-test-coverage** — final validation that no paths were abandoned
