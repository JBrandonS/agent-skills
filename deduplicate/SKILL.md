---
name: deduplicate
description: A skill for identifying and refactoring duplicate code across a codebase. Use this skill when you want to improve code maintainability and reduce technical debt by consolidating similar code patterns into reusable components. This skill should only be used when explicitly asked for, if the user asks to refactor code or ask if they want to deduplicate the code. It is risky, time intensive and token consuming. It may introduce bugs if not done carefully.
---

# Deduplication Skill

## Purpose

The Deduplication Skill is designed to help developers identify and refactor duplicate code across a codebase. By consolidating similar code patterns into reusable components, this skill aims to improve code maintainability and reduce technical debt. Duplicate code increases maintenance burden, introduces inconsistencies, and makes it harder to implement bug fixes consistently across the application.

## When to Use

Use this skill when:
- Developers are making the same fix to similar code in multiple places
- You notice copy-pasted code patterns across modules or components
- Tests require changes in multiple places due to duplicated logic
- Code smell reviews indicate high duplication metrics
- Onboarding new team members requires understanding multiple implementations of the same concept
- You want to consolidate client-side and server-side implementations of the same algorithm

## Prerequisites

- **jscpd skill**: A skill that integrates with jscpd to facilitate the deduplication process.
  - If either this is not found, offer to install it: `npx skills add kucherenko/jscpd`
  - GitHub repo: `https://github.com/kucherenko/jscpd`
- **Version control**: All work should be in a git worktree to enable reverting changes if refactoring introduces regressions

## Workflow

**Overview**: Break down the deduplication process into manageable steps to ensure a systematic approach, you may want to add these to the TODO list as well to keep track of progress and ensure that you don't miss any important steps. This prevents making too many changes at once and helps isolate the impact of each refactoring.:
  0. Split workflow into steps
  1. Identify duplicates using jscpd
  2. Review duplicates for refactoring candidates
  3. Refactor code into shared components
  4. Test changes thoroughly
  5. Abstract common logic patterns
  6. Document the refactor
  7. Iterate and continuous improvement

---

### 0. Split Workflow into Steps

Break down the deduplication process into manageable steps to ensure a systematic approach. This prevents making too many changes at once and helps isolate the impact of each refactoring.

**Details:**

Plan to:
- Scan and categorize duplicates by type (exact duplicates vs. similar patterns)
- Group related duplicates by module or domain
- Prioritize high-impact duplicates (frequently modified, widely distributed)
- Batch refactoring by component to limit review scope

### 1. Identify Duplicates

Use jscpd to scan the codebase and generate a report of duplicate code segments.

**Details:**

**Detailed Steps:**
1. Run jscpd with appropriate filters:
   ```bash
   jscpd --reporters json --reporters html --min-lines 3 --min-tokens 30 .
   ```
2. Review the generated reports (JSON for processing, HTML for visual inspection)
3. Filter out false positives (generated code, vendor files, test fixtures)
4. Categorize duplicates:
   - **Exact duplicates**: Identical code that can be extracted to a shared function
   - **Similar patterns**: Code with minor variations that might need parameterization
   - **Structural duplicates**: Similar workflows in different modules that could share logic

**Configuration Tips:**
- Adjust `--min-lines` and `--min-tokens` thresholds:
  - Higher thresholds reduce noise but may miss small duplicates
  - Start with 3-5 lines for meaningful duplication detection
- Exclude directories: `--exclude "node_modules,dist,build,.git"`
- Consider language-specific analysis if your repo is polyglot

**Example Output:**
```
File: src/services/user.ts (100 lines, 50 tokens)
File: src/services/admin.ts (100 lines, 50 tokens)
Similarity: 85%
```

### 2. Review Duplicates

Analyze the report to understand the context of the duplicates and determine if they can be refactored into a single reusable component.

**Details:**

**Detailed Steps:**
1. For each duplicate group, examine the source files:
   - Understand the purpose and context of each copy
   - Check if copies diverged due to different requirements or oversight
   - Verify that refactoring won't hide important domain differences
2. Ask critical questions:
   - **Why does this duplication exist?** (Oversight, copy-paste, independent development)
   - **Are these truly duplicates or similar-but-different?** (Different business logic might look similar structurally)
   - **What's the cost of consolidation vs. cost of maintaining duplicates?**
   - **Are the copies likely to diverge or remain synchronized?**
3. Document findings for each duplicate group:
   - Root cause of duplication
   - Proposed abstraction strategy
   - Risk assessment (low/medium/high)
   - Expected maintenance savings

**Red Flags to Avoid Refactoring:**
- Domain-specific logic that appears similar but serves different purposes
- Performance-critical hot paths where shared functions add overhead
- Platform-specific or environment-specific code that needs isolation
- New code that hasn't reached stability yet (defer consolidation)

**Example Review:**
```
Duplicate: Input validation in checkout.ts and subscription.ts

Analysis:
- Both validate email and card fields
- Checkout has additional country/zip validation
- Subscription allows optional card (recurring stored)
- Refactoring Strategy: Extract core validation rules to shared util,
  compose with domain-specific validators
- Risk: Low - validation logic is stable and unit-tested
- Savings: Reduce maintenance of 2x validator implementations
```

### 3. Refactor Code

Use the jscpd skill to assist in refactoring the identified duplicates. This may involve creating new functions, classes, or modules to encapsulate the shared logic.

**Details:**

**Detailed Steps:**
1. Choose abstraction level:
   - **Function extraction**: For simple, single-purpose duplicated logic
   - **Utility module**: For related sets of functions used across modules
   - **Shared class or service**: For duplicated OOP patterns or stateful logic
   - **Higher-order function**: For duplicated patterns with minor parameter variations
2. Extract shared code:
   - Create a new module/file in a logical location (typically `src/shared/` or `src/utils/`)
   - Copy the base implementation from the cleanest duplicate
   - Add parameters for points of variation
   - Add JSDoc comments explaining purpose and usage
3. Update all callers to use the shared implementation
4. Remove or stub out redundant copies

**Extraction Strategies by Pattern:**

**Pattern 1: Exact Duplicates**
```typescript
// Before: Repeated in 3+ files
function validateEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

// After: Extract to src/shared/validators.ts
export function validateEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

// All callers updated
import { validateEmail } from '@shared/validators';
```

**Pattern 2: Similar Logic with Minor Variations**
```typescript
// Before: Two similar data-fetching implementations
// user-service.ts
function fetchUser(id: string) {
  return fetch(`/api/users/${id}`)
    .then(r => r.json())
    .catch(err => console.error('User fetch failed', err));
}

// admin-service.ts
function fetchAdmin(id: string) {
  return fetch(`/api/admins/${id}`)
    .then(r => r.json())
    .catch(err => console.error('Admin fetch failed', err));
}

// After: Parameterized function
// src/shared/api.ts
export function fetchResource(endpoint: string) {
  return fetch(endpoint)
    .then(r => r.json())
    .catch(err => console.error(`Fetch from ${endpoint} failed`, err));
}

// Callers
const user = await fetchResource('/api/users/${id}');
const admin = await fetchResource('/api/admins/${id}');
```

**Pattern 3: Structural Duplication (OOP)**
```typescript
// Before: Two similar manager classes
class UserManager {
  items: User[] = [];
  add(item: User) { this.items.push(item); }
  find(id: string) { return this.items.find(i => i.id === id); }
}

class ProductManager {
  items: Product[] = [];
  add(item: Product) { this.items.push(item); }
  find(id: string) { return this.items.find(i => i.id === id); }
}

// After: Generic base class
abstract class EntityManager<T extends { id: string }> {
  protected items: T[] = [];
  add(item: T) { this.items.push(item); }
  find(id: string) { return this.items.find(i => i.id === id); }
}

class UserManager extends EntityManager<User> {}
class ProductManager extends EntityManager<Product> {}
```

### 4. Test Changes

After refactoring, ensure that all tests pass and that the functionality remains intact. This step is crucial to maintain the integrity of the codebase after changes. You may want to use the `tdd` skill to assist in writing and running tests for the refactored code.

**Details:**

**Detailed Steps:**
1. **Run existing test suite**:
   ```bash
   npm test  # or your test command
   ```
   - If tests fail, investigate whether the refactoring introduced a bug or tests need updating
   - Update tests that directly test the old implementation to use the new shared one
2. **Verify behavior equivalence**:
   - Test the new shared implementation with inputs from all original locations
   - Check edge cases that might have been handled differently in duplicates
3. **Add integration tests** (if not already present):
   - Test the new shared code in the context of its actual consumers
   - Verify that all call sites work correctly
4. **Performance testing** (if applicable):
   - For extracted functions in hot paths, measure performance impact
   - Some consolidation may add slight overhead (worth checking)

**Example Test Update:**
```typescript
// Before: Tests for old duplicate
describe('user-service', () => {
  it('fetches user', () => {
    // ...test validateEmail implementation
  });
});

describe('admin-service', () => {
  it('fetches admin', () => {
    // ...test same validateEmail implementation again
  });
});

// After: Single test for shared implementation
describe('shared/validators', () => {
  it('validates email', () => {
    // ...test once in shared location
  });
});
```

### 5. Abstract Common Logic

Analyze the codebase for shared logic, and consider abstracting this logic into a utility function or a shared service that can be reused across the codebase.

**Details:**

**Detailed Steps:**
1. Look for patterns beyond direct duplicates:
   - Similar algorithms with different names
   - Repeated error handling patterns
   - Common data transformations
   - Recurring state management patterns
2. Identify opportunities for higher-level abstractions:
   - Can several functions be unified into a single configurable function?
   - Would a shared base class or mixin reduce boilerplate?
   - Could a design pattern (strategy, factory, decorator) apply?
3. Create abstractions incrementally:
   - Start with concrete implementations, generalize only if pattern repeats 3+ times
   - Document the abstraction's purpose and constraints

**Example: From Concrete to Abstract**
```typescript
// Stage 1: Identify duplicated pattern
// Report loading in 3+ services

// Stage 2: Extract concrete function
// src/shared/report-loader.ts
export function loadReport(endpoint: string, retries = 3) {
  // Implementation specific to reports
}

// Stage 3: Generalize to abstract pattern
// src/shared/retry-fetcher.ts
export function withRetry<T>(
  operation: () => Promise<T>,
  maxRetries = 3
): Promise<T> {
  // Generic retry logic
}

// Now reports, users, products all use same retry pattern
```

### 6. Document Refactor

Update any relevant documentation to reflect the changes made during the deduplication process.

**Details:**

**Detailed Steps:**
1. **Update module documentation**:
   - Add README or JSDoc comments to newly created shared modules
   - Explain when and how to use the shared implementation
   - Note any assumptions or constraints
2. **Update architecture docs** (if they exist):
   - Document the new module structure
   - Explain which modules should share code and why
3. **Add inline comments** for non-obvious design decisions:
   - Why certain code was consolidated
   - Why some apparent duplicates were NOT consolidated
4. **Update migration guides** for team members:
   - If old module locations changed, document the new location
   - Provide examples of how to use the new shared code

**Example Documentation:**
```typescript
/**
 * Shared email validation rules.
 * 
 * These validators are used across checkout, account, and subscription flows.
 * Use these to ensure consistent email handling across the application.
 * 
 * Example:
 *   import { validateEmail } from '@shared/validators';
 *   if (validateEmail(userInput)) { ... }
 * 
 * Note: These are permissive validators suitable for UI-level validation.
 * Backend should perform additional validation before persistence.
 */
export function validateEmail(email: string): boolean { ... }
```

### 7. Iterate

Repeat the process as needed to continuously improve the codebase and reduce technical debt over time.

**Details:**

**Detailed Steps:**
1. **Schedule regular deduplication reviews**:
   - As part of sprint planning, allocate time for duplication reduction
   - Track duplication metrics over time to measure improvement
2. **Educate the team**:
   - Share findings from this deduplication session
   - Establish guidelines for when to extract vs. copy code in future development
   - Use examples from your codebase in code reviews
3. **Prevent new duplication**:
   - During code reviews, flag duplicate patterns early
   - When adding similar features, search for existing implementations first
4. **Revisit lower-priority duplicates**:
   - Not all duplicates have the same urgency
   - Consolidate higher-risk, high-impact duplicates first
   - Revisit lower-priority ones in future iterations

## Best Practices

### DO:
- ✅ Start with high-impact duplicates (frequently changed, widely distributed)
- ✅ Extract small, focused functions with single responsibility
- ✅ Write comprehensive tests before and after refactoring
- ✅ Use version control branches for deduplication work (enables rollback)
- ✅ Keep extracted functions in logical, discoverable locations
- ✅ Add type hints and clear documentation to shared code
- ✅ Review deduplication in code review as you would normal refactoring
- ✅ Consider performance implications of adding shared function call overhead
- ✅ Batch related refactorings together for easier review

### DON'T:
- ❌ Over-abstract: Don't consolidate code that's genuinely different (DRY vs. WET tradeoff)
- ❌ Refactor untested code: Deduplication is risky; ensure coverage first
- ❌ Consolidate before divergence settles: Wait for code to stabilize
- ❌ Break backward compatibility without deprecation period
- ❌ Extract code you don't fully understand (leads to subtle bugs)
- ❌ Create deeply nested abstractions that hide business logic
- ❌ Ignore performance: Some consolidation may add latency (measure!)
- ❌ Skip testing edge cases that might exist in only one original copy

## Troubleshooting

### Issue: jscpd reports false positives (common framework boilerplate)

**Solution:**
- Configure `.jscpdignore` or jscpd config to exclude patterns:
  ```json
  {
    "ignore": ["node_modules", "dist", "**/*.d.ts"],
    "minLines": 5,
    "minTokens": 50
  }
  ```

### Issue: Refactoring breaks functionality in unexpected ways

**Solution:**
- Ensure comprehensive test coverage exists before refactoring
- Use smaller extraction steps (extract one function at a time, test after each)
- Compare behavior of original and refactored code with identical inputs
- Check for side effects or state mutations in extracted code

### Issue: Extracted code is too generic and hard to understand

**Solution:**
- Reconsider if consolidation is worth the complexity cost
- Add clear documentation and examples to the shared code
- Consider creating domain-specific wrapper functions over generic logic
- Use more descriptive parameter names and types

## Related Skills

- **code-knowledge**: Use to understand code structure and identify duplicates across the codebase. Index will need to updated and retrained after deduplication to reflect the new structure of the codebase, and to ensure that future searches return accurate results. Be sure to load have this in context before starting.
- **tdd**: Use when writing tests for deduplication to ensure correctness
- **code-reusability**: For refactoring code to be more reusable, which often goes hand in hand with deduplication. After identifying duplicates, you may want to apply code-reusability principles to create shared components that can be reused across the codebase, further reducing duplication and improving maintainability.
- **improve-codebase-architecture**: For broader refactoring beyond just deduplication, once deduplication has been addressed ask if the user would like to improve the codebase architecture as well, as they often go hand in hand.

