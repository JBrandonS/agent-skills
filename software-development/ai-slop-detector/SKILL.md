---
name: ai-slop-detector
description: Detects AI-generated code anti-patterns and prevents AI slop from entering a codebase. Use during code review, CI gates, or when reviewing PRs that may contain AI-generated code. Triggers on phrases like "check for AI code", "detect slop", "review this AI code", "prevent AI patterns", or when the user asks to scan for AI-written code tells.
---

# AI Slop Detector

Detect and prevent AI-written code anti-patterns using static analysis heuristics, structural checks, and review prompts. See [REFERENCE.md](REFERENCE.md) for the complete catalog of AI tells.

## Quick Review Checklist (PR Review)

When reviewing suspected AI-generated code:

1. **Comments** — Explaining what, not why? Tutorial-style prose?
2. **Names** — Generic noun clusters (`data`, `result`, `value`)? Textbook naming?
3. **Error handling** — Happy path perfect but catch blocks generic or missing?
4. **Style comparison** — Does this file look different from the codebase?
5. **Complexity** — Simple problem solved with complex structure?
6. **Placeholders** — TODOs, stubs, empty functions left behind?
7. **Imports** — Unused or hallucinated packages?

### Review Prompts for Suspected AI Code

Ask the author to explain their choices:
- "Can you walk me through your approach?" (if they can't explain, it's likely AI)
- "Why this structure over alternatives?"
- "What edge cases did you consider?"
- "How does this fit existing codebase patterns?"

## AST-Grep Detection Patterns

Run against a codebase to find suspicious patterns:

### Python
```bash
# Empty stubs
ast_grep_search --lang python -p 'def $FUNC($$$): pass'

# Docstrings on simple functions
ast_grep_search --lang python -p 'def $FUNC($$$):\n    """$DOC"""'

# Silent exception swallowing
ast_grep_search --lang python -p 'except Exception:\n    pass'
```

### JavaScript/TypeScript
```bash
# Empty catch blocks
ast_grep_search --lang typescript -p '} catch ($ERR) { console.log($ERR); }'

# Unnecessary async (then check body for absence of await)
ast_grep_search --lang typescript -p 'async function $FUNC($$$): $$$'

# Generic variable names
ast_grep_search --lang typescript -p 'let data: any; const result = $$$;'
```

**Full pattern catalog**: [detection-patterns-python.md](detection-patterns-python.md), [detection-patterns-javascript.md](detection-patterns-javascript.md)

## Pre-Commit Prevention (Agent Instructions)

Add to agent/system prompts:
```
Write minimum code that satisfies the requirement.
Prefer functions over classes. Prefer flat over nested.
Do not add features, abstractions, or error handling beyond what is specified.
Follow existing codebase patterns — naming, style, and structure must match surrounding code.
```

## CI Gate Metrics (Ongoing Monitoring)

For changed files, track:
1. **Comment density**: Ratio of comment lines to code lines vs project average
2. **Naming entropy**: Distribution of name lengths and generic word frequency
3. **Structure uniformity**: Std dev of function lengths/complexities in a file
4. **Import utilization**: Used imports / total imports per file
5. **Style consistency**: Compare against existing files (indentation, braces, naming)

## Scoring Model

| Signal | Weight | Severity |
|--------|--------|----------|
| Hallucinated APIs | 0.25 | Critical |
| Empty stubs/placeholders | 0.15 | High |
| Happy path bias | 0.12 | Medium |
| Comment echo density | 0.10 | Medium |
| Naming entropy low | 0.10 | Low |
| Over-engineering | 0.08 | Medium |
| Inhuman consistency | 0.08 | Low |
| Stylistic discontinuity | 0.07 | Medium |
| Missing real-world context | 0.05 | Low |

**Score > 0.4**: Flag for human review
**Score > 0.6**: Likely AI-generated, needs rewrite or author verification
