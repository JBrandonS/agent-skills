# AI Tells Reference Catalog

Complete catalog of AI-written code signals organized by category. These are patterns to look for during review — no single signal is definitive; look for clusters of tells.

## 1. Comment Tells

### Echo Comments
Comments describing WHAT the code does rather than WHY:
```python
i += 1  # increment counter by 1
return True  # return true if valid
```
**Signal**: The comment restates the code literally. Humans explain intent; AI explains syntax.

### Over-Commenting Trivial Operations
Every helper function gets a docstring header. Every line of logic has an explanation. Simple utility functions with multi-line documentation.

### Tutorial-Style Prose
Comments read like textbook explanations rather than developer notes:
```python
# This function validates the user input and ensures that the
# provided data meets all the necessary requirements before
# being processed by the application logic.
def validate_input(data): ...
```

### LLM Verbal Tics in Comments
- "Ensure that..."
- "Here is a simple example..."
- "Note that..."
- "Crucially..."

## 2. Naming Tells

### Low Entropy Names
Generic, statistically probable names that appear across many files:
- `data`, `result`, `value`, `temp`, `item`, `obj`, `res`

**Signal**: 3+ generic nouns in a single file.

### Textbook Variable Names
Overly descriptive compound names that sound like API design:
- `input_data_stream`, `calculation_result_final`, `loop_index`, `user_authentication_token`

### Placeholder Naming
`placeholder`, `dummy`, `stub`, `fakeData`, `testValue` — AI leaves these when unsure about implementation.

## 3. Structural Tells

### Inhuman Consistency
- Perfectly aligned object properties
- Alphabetically ordered imports without a linter
- Every case in a switch handled, including impossible ones
- Uniform spacing everywhere

**Signal**: Looks like it was formatted by Prettier before it was even written.

### Repetitive Block Structures
Every function follows the same skeleton: Validate → Process → Return. Same error handling pattern repeated across all functions.

### Over-Engineering Simple Problems
- A simple file reader implemented with classes, interfaces, and dependency injection
- 150 lines where 30 would do
- Unrequested features (rate limiting, analytics, webhooks) added to a basic notification request

**Source**: [Abstraction Bloat in AI Agent-Generated Code](https://agentpatterns.ai/anti-patterns/abstraction-bloat/) — agents are optimized to look comprehensive, not minimal.

### Perfectly Balanced Functions
All functions similar length and complexity. No dead imports, no trailing commas, no accidental debug `print()`.

## 4. Happy Path Bias

Success case handled perfectly but:
- Generic catch blocks: `catch (e) { console.log(e) }` or `except Exception: pass`
- Silent error swallowing everywhere
- Missing: network timeouts, malformed JSON responses, race conditions, retries, rate limiting
- Functions with zero edge-case handling because they assume everything works

**Signal**: Code that "works" in tests but would fail under real-world conditions.

## 5. Anti-Patterns

### Empty Stubs and Placeholders
```python
def feature(): pass
return None
= NotImplemented
...  # TODO placeholder
```
AI often generates scaffolding and leaves empty implementations behind.

### Phantom Imports
Imported modules/packages that are never used in the file body. AI "thinks about" tools for a task but fails to prune unused ones from the final output.

### Unnecessary Async
`async` functions without any `await` in their body. AI adds async/await promiscuously.

### Redundant Null Checks
Multiple null/None checks on the same variable:
```typescript
if (!obj) throw new Error('...');
if (obj === null) throw new Error('...');
if (typeof obj === 'undefined') throw new Error('...');
```

### Excessive Parameter Validation
Validation in every function including private helpers, even when the contract is guaranteed by design.

## 6. Hallucinations

References to non-existent library functions, methods, or parameters:
- `Array.prototype.flatten()` (doesn't exist in older environments)
- `Object.hasOwn($$$)` (only available in Node 16+)
- Fabricated method chains like `$obj.method().then().finally().json()`
- Outdated APIs used as current patterns

**Signal**: Code that compiles/passes linter but has phantom API calls.

## 7. Missing Real-World Context

Self-contained code operating in a vacuum:
- No config files or `.env` usage
- No logging
- No retries for external calls
- No rate limiting
- No auth token handling
- No error handling for timeouts or malformed responses

**Signal**: Code that reads like a tutorial example rather than production code.

## 8. Stylistic Discontinuity

The file looks different from the surrounding codebase:
- Different naming conventions (camelCase vs snake_case)
- Different error handling patterns
- Different logging formats
- Looks "polished" compared to the rest of the codebase
- Different brace style, indentation, or import ordering

**Signal**: A file that feels like it was written by a different author.

## 9. Commit Tells (Git History)

Unusual commit patterns that reflect AI tool usage:
- **Large single commits**: 500+ line files appearing in one commit with generic message
- **Commit timing**: 200+ lines added in 15 minutes
- **Followed by correction commits**: Large AI commit immediately followed by small fix commits (`fix typo`, `add missing validation`)
- **Prompt-as-commit-message**: `add user authentication with JWT`

## 10. Lexical/Token Patterns (Research-Backed)

Based on [DetectCodeGPT research](https://arxiv.org/html/2401.06461v4):
- **Narrower token spectrum**: AI uses fewer unique tokens, adhering to common paradigms
- **More concise code**: Machine-authored code is more compact than human code
- **Regular whitespace patterns**: AI has predictable spacing; humans have idiosyncratic whitespace
- **Higher "naturalness"**: AI code can appear MORE natural because it follows learned patterns without human quirks

Based on [Empirical Study of AI Code in Real Repos](https://arxiv.org/html/2603.27130v2):
- **Verbosity**: AI code is consistently more verbose in tokens and operators
- **Higher blank-line ratio**: 15% vs 13% for human code
- **Lower cross-file duplication**: AI doesn't reuse patterns across files like humans do
