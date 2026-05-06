---
name: code-compaction
description: >
  Reduce code size and file count to improve AI agent token ingestion.
  Focus on logical reordering, deduplication, file splitting, inheritance,
  and leveraging built-in language features. Uses TDD for safety and
  code-coverage to verify no regressions. Trigger on phrases like
  "compact this", "reduce code size", "shrink the codebase", "make it
  more token-efficient", "optimize for AI ingestion", or any request to
  reduce LOC/file count without changing behavior.
tags: [compaction, deduplication, refactoring, token-efficiency, ai-ingestion]
related_skills: [deduplicate, test-driven-development, code-coverage, code-reusability]
---

# Code Compaction Skill

## Purpose

Reduce the size of a codebase — fewer lines, smaller files, fewer files total — so AI agents can ingest it within token limits while preserving all behavior. This is not about premature optimization or sacrificing readability; it's about eliminating waste: duplicated logic, bloated files, missed language features, and structural bloat.

**Core principle:** Smaller code = better AI comprehension. Fewer files = fewer context switches. Shared abstractions = less duplication to reason about.

## When to Use

Use this skill when:
- An AI agent runs out of context window while reading the codebase
- Files exceed reasonable size limits (e.g., >500–1000 lines)
- The codebase has obvious duplication, bloated modules, or missed abstractions
- The user explicitly asks to "compact", "shrink", "reduce LOC", or "optimize for AI ingestion"
- Preparing a codebase for AI-assisted development where context window is constrained

## Prerequisites

- **Version control**: All work in a git branch. Never compact on main without being able to revert.
- **Tests exist**: If no test suite exists, create minimal tests first (use `test-driven-development` skill). Compacting untested code is dangerous.
- **Load related skills**: `deduplicate`, `test-driven-development`, and `code-coverage` must be loaded before starting.

## Workflow

**Overview**: Systematic compaction in phases:
0. Audit the codebase — measure size, identify candidates
1. Logical reordering — improve structure without changing behavior
2. Deduplication — run the `deduplicate` skill to eliminate repeated code
3. File splitting — break large files into smaller, focused modules
4. Inheritance & composition — use OOP patterns to share behavior
5. Language features — leverage built-in tools, idioms, and standard library
6. Test with TDD — verify every change preserves behavior using `test-driven-development`
7. Verify coverage — run `code-coverage` skill to confirm no regressions

---

### 0. Audit the Codebase

Measure the current state before making changes. Establish a baseline.

**Detailed Steps:**

1. **File-level metrics**:
   ```bash
   # Lines of code per file (exclude node_modules, .git, dist, build)
   find . -name "*.py" -o -name "*.ts" -o -name "*.js" | \
     grep -v node_modules | grep -v .git | grep -v dist | grep -v build | \
     xargs wc -l | sort -n | tail -20
   ```

2. **Total LOC**:
   ```bash
   find . -name "*.py" -o -name "*.ts" -o -name "*.js" | \
     grep -v node_modules | grep -v .git | grep -v dist | grep -v build | \
     xargs wc -l | tail -1
   ```

3. **Identify large files** (>500 lines for Python/TS, >1000 for JS):
   ```bash
   find . -name "*.py" -o -name "*.ts" -o -name "*.js" | \
     grep -v node_modules | grep -v .git | grep -v dist | grep -v build | \
     xargs wc -l | sort -rn | head -10
   ```

4. **Identify duplication** (run `deduplicate` skill workflow — Step 1):
   ```bash
   jscpd --reporters json --min-lines 3 --min-tokens 30 .
   ```

5. **Record baseline**:
   - Total LOC
   - File count
   - Largest files
   - Duplication percentage (from jscpd)

**Output format:**
```
Baseline:
- Total LOC: X
- File count: Y
- Largest file: path/to/file (Z lines)
- Duplication: ~N%
```

---

### 1. Logical Reordering

Reorganize code within files to improve readability and structure without changing behavior. This is the lowest-risk compaction step.

**Detailed Steps:**

1. **Sort imports**: Group by standard library → third-party → local. Alphabetize within groups. Remove unused imports.
   ```bash
   # Python: use isort
   isort .
   # TypeScript: use eslint --fix or prettier
   npx eslint --fix src/
   ```

2. **Reorder within files**: Follow language conventions:
   - **Python**: `__init__` first, then public methods, then private methods, then module-level helpers
   - **TypeScript/JS**: Type definitions/interfaces first, then implementation, then exports
   - **General**: Higher-level abstractions before lower-level details (top-down)

3. **Remove dead code**: Identify and remove unreachable functions, unused parameters, commented-out blocks.
   ```bash
   # Python: find unused imports
   pyflask src/  # or pylint --disable=all --enable=unused-import src/
   ```

4. **Consolidate small files**: If a file has only 1–2 trivial functions and is in the same module, consider merging it into its primary consumer.

**Rules:**
- Do NOT change behavior — only reorder
- Do NOT merge files that serve different concerns
- Verify tests still pass after each reordering batch

---

### 2. Deduplication

Run the `deduplicate` skill to identify and consolidate repeated code patterns. This is the single highest-impact compaction step.

**Detailed Steps:**

1. **Load the `deduplicate` skill** and follow its workflow (Steps 0–7).
2. Focus on **exact duplicates** first — these are the easiest and safest to remove.
3. Then tackle **similar patterns** that can be parameterized.
4. Finally address **structural duplication** (OOP patterns, repeated class hierarchies).

**Key compaction-specific considerations:**
- Prioritize duplicates that appear in **large files** — removing them has the biggest LOC impact
- When extracting shared code, place it in a logical `shared/`, `common/`, or `utils/` module
- Each successful deduplication reduces both LOC and file context requirements for AI agents

**After deduplication:**
- Update baseline metrics
- Record LOC reduction
- Verify all tests pass (use `test-driven-development` skill)

---

### 3. File Splitting

Break large, monolithic files into smaller, focused modules. This reduces per-file token load for AI agents even though total file count increases.

**Detailed Steps:**

1. **Identify files to split** — candidates are files with:
   - >500 lines (Python/TypeScript) or >1000 lines (JavaScript)
   - Multiple distinct responsibilities (e.g., a file with both data models AND API handlers AND business logic)
   - Clear natural boundaries (e.g., a `main.py` that does everything)

2. **Identify split boundaries** — look for:
   - Distinct classes or groups of functions serving different domains
   - Data structures vs. behavior
   - Input/validation vs. processing vs. output
   - Separate concerns that could be independently tested

3. **Create new files**:
   ```
   # Before: app.py (800 lines)
   # After:
   app/
     __init__.py        # re-exports for backward compatibility
     models.py          # data classes, schemas
     validators.py      # input validation logic
     handlers.py        # request/response handling
     business.py        # core domain logic
     utils.py           # shared helpers (if any remain)
   ```

4. **Update imports** in all files that reference the split file.

5. **Maintain backward compatibility** — if other modules import from the old file, add re-exports:
   ```python
   # app/__init__.py
   from .models import User, Product
   from .handlers import handle_request
   ```

6. **Verify tests pass** after each split.

**Rules:**
- Each new file should have a single clear responsibility
- Do not split files that are already small (<100 lines)
- Preserve the public API — external consumers should not need changes
- Run `deduplicate` on the new files — splitting often reveals cross-file duplication

---

### 4. Inheritance & Composition

Use OOP patterns to share behavior across classes and reduce code size.

**Detailed Steps:**

1. **Identify shared behavior**:
   - Multiple classes with the same methods (e.g., `save()`, `delete()`, `validate()`)
   - Classes that differ only in data, not structure
   - Repeated error-handling or logging patterns

2. **Apply inheritance** when:
   - Classes share both interface AND implementation
   - There is a clear "is-a" relationship
   ```python
   # Before: Duplicated base logic in 3 classes
   class UserRepository:
       def find_by_id(self, id): ...
       def save(self, obj): ...
       def delete(self, id): ...

   class ProductRepository:
       def find_by_id(self, id): ...
       def save(self, obj): ...
       def delete(self, id): ...

   # After: Shared base class
   class BaseRepository(ABC):
       @abstractmethod
       def find_by_id(self, id): ...

       def save(self, obj):
           self._validate(obj)
           self._persist(obj)

       def delete(self, id):
           self._validate_id(id)
           self._remove(id)

   class UserRepository(BaseRepository):
       def find_by_id(self, id):
           return db.query(User).filter(id=id).first()
   ```

3. **Apply composition** when:
   - Classes share behavior but not identity
   - Multiple inheritance would be messy
   - Behavior is truly interchangeable
   ```python
   # Before: Repeated logging in every class
   class ServiceA:
       def run(self):
           self.logger.info("ServiceA running")
           ...

   class ServiceB:
       def run(self):
           self.logger.info("ServiceB running")
           ...

   # After: Mixin or composition
   class Loggable:
       def log(self, msg):
           logger.info(f"[{self.__class__.__name__}] {msg}")

   class ServiceA(Loggable):
       def run(self):
           self.log("running")
           ...
   ```

4. **Use interfaces/ABCs** to define contracts without implementation overhead:
   ```python
   from abc import ABC, abstractmethod

   class Serializable(ABC):
       @abstractmethod
       def to_dict(self) -> dict: ...

       @abstractmethod
       def from_dict(cls, data: dict) -> 'Serializable': ...
   ```

**Rules:**
- Prefer composition over inheritance when possible (more flexible, less fragile)
- Do not create deep inheritance hierarchies (>3 levels)
- Each level of inheritance should add meaningful behavior, not just pass through
- After applying inheritance, run `deduplicate` to catch any remaining patterns

---

### 5. Language Features

Leverage built-in language features, standard library functions, and idiomatic patterns to replace verbose custom code.

**Detailed Steps:**

1. **Python-specific optimizations**:
   ```python
   # Before: Verbose loop
   result = []
   for item in items:
       if item.active:
           result.append(item.name)

   # After: List comprehension
   result = [item.name for item in items if item.active]

   # Before: Manual dict building
   d = {}
   for k, v in pairs:
       if k not in d:
           d[k] = []
       d[k].append(v)

   # After: defaultdict
   from collections import defaultdict
   d = defaultdict(list)
   for k, v in pairs:
       d[k].append(v)

   # Before: Manual enum-like class
   class Status:
       PENDING = 0
       RUNNING = 1
       DONE = 2

   # After: Enum
   from enum import IntEnum
   class Status(IntEnum):
       PENDING = 0
       RUNNING = 1
       DONE = 2

   # Before: Manual string formatting
   msg = "User " + str(user.id) + " logged in at " + str(timestamp)

   # After: f-string
   msg = f"User {user.id} logged in at {timestamp}"

   # Before: Manual None checks
   name = user.name
   if name is None:
       name = "Unknown"

   # After:walrus or coalesce
   name = user.name or "Unknown"
   ```

2. **TypeScript/JavaScript-specific optimizations**:
   ```typescript
   // Before: Verbose null checks
   const name = user !== null && user !== undefined ? user.name : 'Unknown';

   // After: Optional chaining + nullish coalescing
   const name = user?.name ?? 'Unknown';

   // Before: Manual array filtering
   const adults = people.filter(p => {
     if (p.age >= 18) {
       return true;
     }
     return false;
   });

   // After: Direct filter
   const adults = people.filter(p => p.age >= 18);

   // Before: Manual destructuring
   const id = obj.id;
   const name = obj.name;
   const email = obj.email;

   // After: Destructuring
   const { id, name, email } = obj;

   // Before: Multiple if-else for dispatch
   function handle(type) {
     if (type === 'A') return doA();
     if (type === 'B') return doB();
     if (type === 'C') return doC();
   }

   // After: Dispatch table
   const handlers = { A: doA, B: doB, C: doC };
   function handle(type) { return handlers[type]?.(); }
   ```

3. **General patterns applicable to all languages**:
   - Use built-in sorting/filtering/mapping instead of manual loops
   - Use standard library utilities (e.g., `itertools` in Python, `lodash` in JS)
   - Replace manual string parsing with regex or language-specific parsers
   - Use pattern matching / switch expressions where available

**Rules:**
- Only replace code with idiomatic equivalents — never sacrifice clarity
- Verify the replacement behaves identically (run tests)
- Do not use obscure or overly clever one-liners that hurt readability

---

### 6. Test with TDD

Every compaction change must be verified using the `test-driven-development` skill. This ensures behavior is preserved.

**Detailed Steps:**

1. **Before each compaction step**, run the full test suite:
   ```bash
   pytest tests/ -q        # Python
   npm test                 # TypeScript/JS (if using Jest)
   ```

2. **For each change**, follow TDD:
   - Write a failing test that captures the expected behavior of the refactored code
   - Watch it fail
   - Apply the compaction change
   - Watch it pass
   - Run full suite to check for regressions

3. **Specific TDD checks for compaction**:
   - After deduplication: Test that extracted function works in all original contexts
   - After file splitting: Test that re-exports work and all imports resolve
   - After inheritance changes: Test that subclasses behave identically to originals
   - After language feature swaps: Test edge cases (empty inputs, null values, etc.)

4. **If any test fails during compaction**:
   - Undo the change immediately
   - Analyze why behavior changed
   - Take smaller steps or skip this particular refactoring

**TDD Integration Checklist:**
- [ ] Full test suite passes before changes
- [ ] Each compaction step has a corresponding TDD cycle
- [ ] Regressions caught and fixed before proceeding
- [ ] No tests added just to pass — tests verify actual behavior

---

### 7. Verify Coverage

After all compaction is complete, run the `code-coverage` skill to ensure no code paths were broken or abandoned.

**Detailed Steps:**

1. **Run coverage analysis**:
   ```bash
   # Python
   coverage run -m pytest && coverage report
   # TypeScript/JS (Jest)
   npx jest --coverage
   ```

2. **Compare to baseline**:
   - Coverage should not decrease significantly
   - If coverage drops, investigate: did a compaction step remove code that was tested? Or did it break an untested path?

3. **Address coverage gaps**:
   - If new code paths are uncovered (from refactoring), add tests
   - If previously covered code is no longer exercised, fix the regression
   - Document any intentionally reduced coverage with `pragma: no cover` or equivalent

4. **Final metrics report**:
   ```
   Compaction Results:
   - Before: X LOC, Y files
   - After: Z LOC, W files
   - Reduction: N% LOC, M% files
   - Coverage: before → after (should be stable or improved)
   - Tests: all passing
   ```

---

## Best Practices

### DO:
- ✅ Start with measurement — know what you're optimizing
- ✅ Work in small batches — one change at a time, test after each
- ✅ Prioritize deduplication — it has the highest ROI for compaction
- ✅ Use version control — always able to revert
- ✅ Preserve the public API — external consumers should not break
- ✅ Keep tests green throughout — if you can't, undo and reassess
- ✅ Document structural changes in commit messages

### DON'T:
- ❌ Compact untested code without adding tests first
- ❌ Sacrifice readability for fewer lines — clarity > brevity
- ❌ Create overly complex abstractions to save a few LOC
- ❌ Split files that are already small and cohesive
- ❌ Deepen inheritance hierarchies just to share a method
- ❌ Use obscure language features that hurt understandability
- ❌ Reduce coverage below acceptable thresholds (typically 80%+)

## Compaction Metrics & Targets

| Metric | Target | Notes |
|--------|--------|-------|
| LOC reduction | 10–30% | Depends on starting state; heavily duplicated code can see >50% |
| File count | Same or fewer | Splitting increases files but reduces per-file size; net effect depends |
| Largest file | <500 lines | Python/TypeScript; <1000 for JS |
| Duplication rate | <5% | From jscpd analysis |
| Coverage | ≥ baseline | Should not decrease after compaction |

## Troubleshooting

### Issue: Compaction breaks behavior
**Solution:** Undo immediately. The TDD cycle should have caught this — if it didn't, add a regression test first before retrying.

### Issue: Deduplication creates fragile abstractions
**Solution:** Not all duplicates should be consolidated. If the duplicated code has diverged significantly or serves different domains, leave them separate. The `deduplicate` skill's Step 2 (Review) exists for this reason.

### Issue: File splitting breaks imports across the codebase
**Solution:** Add re-exports in the module's `__init__.py` (Python) or index file to maintain backward compatibility. Update internal imports gradually.

### Issue: Coverage drops after compaction
**Solution:** Coverage drop means either: (a) tested code was removed (good — it was dead), or (b) untested code was broken (bad). Investigate the specific uncovered lines. If (b), fix the regression and add tests for the new paths.

### Issue: AI agent still runs out of context
**Solution:** Compaction alone may not be enough. Consider: (a) creating a `CONTEXT.md` summarizing the codebase architecture, (b) using the `code-knowledge` skill to build an index, (c) splitting the AI's work into per-file tasks rather than loading everything at once.

## Related Skills

- **deduplicate**: Primary compaction tool — eliminates duplicated code. Load before starting this skill.
- **test-driven-development**: Safety net for all compaction changes. Every change must pass TDD verification.
- **code-coverage**: Final validation step. Run after all compaction to confirm no regressions.
- **code-reusability**: Complementary analysis — identifies opportunities for inheritance, composition, and abstraction that enable compaction.
- **improve-codebase-architecture**: Broader structural improvements that often accompany compaction efforts.

## Workflow Summary (Quick Reference)

```
0. Measure baseline (LOC, files, duplication)
1. Reorder imports and code structure (no behavior change)
2. Run deduplicate skill → extract shared code
3. Split large files → focused modules with re-exports
4. Apply inheritance/composition for shared behavior
5. Replace verbose code with language idioms
6. TDD verify every change (RED-GREEN-REFACTOR)
7. Run code-coverage skill → confirm no regressions
8. Report before/after metrics
```
