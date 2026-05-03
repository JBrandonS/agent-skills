---
name: code-reusability
description: >
  Analyze and improve code reusability using DRY, KISS, SOLID, modular design, OOP, and design patterns.
  Use this skill whenever the user wants to: audit code for reusability issues, refactor code to be more
  reusable, review a codebase for duplication, check if code follows DRY/SOLID/KISS principles, improve
  modularity or component design, or get a report on reusability health. Trigger on phrases like "make
  this more reusable", "refactor for reuse", "check my code", "is this DRY?", "code duplication",
  "modular", "clean up this code", "reusability report", or any request to audit or fix code quality.
---

# Code Reusability Skill

This skill helps AI audit and improve code for reusability using industry best practices. It supports
two operating modes:

- **`report`** — Analyze code and produce a detailed reusability report with findings and recommendations (no changes made).
- **`refactor`** — Analyze code and actively apply fixes, returning improved code with an explanation of changes.

---

## Step 1: Determine Mode

If the user has not explicitly stated a mode, infer from their language:

| User language | Mode |
|---|---|
| "just check", "review", "audit", "what's wrong", "give me a report", "analyze" | `report` |
| "fix", "refactor", "clean up", "improve", "rewrite", "make it better" | `refactor` |

If ambiguous, **ask**:
> "Would you like me to (a) give you a reusability report with recommendations, or (b) refactor the code directly?"

---

## Step 2: Analyze the Code

Evaluate the code against each of the following principles. Note violations and severity for each.

### Principles Checklist

#### DRY — Don't Repeat Yourself
- [ ] Is the same logic copy-pasted in multiple places?
- [ ] Are there functions or classes that do nearly the same thing?
- [ ] Are there magic numbers or strings duplicated rather than defined as constants?
- [ ] Could repeated blocks be extracted into a shared utility?

#### KISS — Keep It Simple, Stupid
- [ ] Are functions/methods doing more than one thing?
- [ ] Are there over-engineered abstractions that add complexity without clear benefit?
- [ ] Is the code readable to a developer unfamiliar with the project?
- [ ] Could any logic be simplified without losing behavior?

#### SOLID Principles
- **Single Responsibility**: Does each class/module have exactly one reason to change?
- **Open/Closed**: Can behavior be extended without modifying existing code?
- **Liskov Substitution**: Do subclasses behave correctly when used as their parent type?
- **Interface Segregation**: Are interfaces/contracts focused, or do they force unused dependencies?
- **Dependency Inversion**: Do high-level modules depend on abstractions, not concretions?

#### Modularity
- [ ] Is code organized into small, cohesive, loosely-coupled units?
- [ ] Can modules be tested and developed independently?
- [ ] Are there clear boundaries between concerns (e.g., data, logic, presentation)?

#### OOP / Component Design (if applicable)
- [ ] Is inheritance used appropriately (not as a shortcut for code sharing)?
- [ ] Are shared behaviors extracted into base classes or mixins?
- [ ] In front-end code: Are UI components parameterized (via props/config) for reuse?

#### Design Patterns
- [ ] Are any common patterns applicable but missing (e.g., Factory, Strategy, Observer)?
- [ ] Are any patterns being misused in ways that add unnecessary complexity?

#### Reusability Metrics to Note
- **Code Duplication Rate**: Estimate percentage of code that appears more than once
- **Function/Method Reuse Ratio**: What proportion of functions are called from multiple places?
- **Component Complexity**: Flag any components/classes that are overly complex (e.g., >200 lines, >5 responsibilities)

---

## Step 3a: Report Mode Output

Produce a structured report with the following sections:

```
## Code Reusability Report

### Summary
[1-2 sentence overall assessment. E.g. "The codebase has moderate reusability. Key issues are significant
DRY violations in the data processing layer and overly large utility classes."]

### Findings

#### 🔴 Critical Issues
[Violations that significantly harm reusability or maintainability. List each with:
- Location (file, function, line range if known)
- Principle violated
- Description of the problem
- Suggested fix]

#### 🟡 Warnings
[Minor violations or areas that could be improved. Same format as above.]

#### 🟢 Good Practices Observed
[Call out what's already done well to give a balanced picture.]

### Recommended Actions
[Prioritized list of concrete changes. Format as:
1. [Highest priority] ...
2. ...
]

### Metrics Estimate
- Code Duplication Rate: ~X%
- Key components needing simplification: [list]
- Estimated refactor effort: [low / medium / high]
```

---

## Step 3b: Refactor Mode Output

Apply the following refactoring strategy:

1. **Fix DRY violations first** — extract duplicated logic into shared functions, constants, or classes.
2. **Apply SOLID** — split classes with multiple responsibilities; introduce interfaces/abstractions where hardcoding exists.
3. **Simplify (KISS)** — remove unnecessary complexity; inline over-abstracted helpers; clarify naming.
4. **Improve modularity** — reorganize code into cohesive units if structure allows.
5. **Apply design patterns** — only where they genuinely simplify; do not introduce patterns for their own sake.

Return the refactored code with a **change summary** below it:

```
## Changes Made

### DRY Fixes
- [Description of extraction/consolidation]

### SOLID Improvements
- [Description of responsibility splits, abstraction changes, etc.]

### Simplifications
- [What was removed or clarified]

### Modularity
- [Any structural reorganization]

### Notes
[Any trade-offs made, things intentionally left unchanged, or follow-up suggestions]
```

---

## Handling Partial or Large Codebases

- If the user provides a **single file or snippet**: analyze fully.
- If the user provides **multiple files**: prioritize the most impactful files; note which were not reviewed.
- If the codebase is **too large to refactor in one pass**: produce the report first, then ask the user which areas to refactor.

---

## Language & Framework Notes

Adapt advice to the language/stack in use:

| Stack | Key considerations |
|---|---|
| JavaScript/TypeScript | Prefer composable hooks/functions; avoid deep inheritance; use ES modules |
| Python | Favor composition; use dataclasses or ABCs for structure; avoid God classes |
| Java/C# | Apply SOLID rigorously; use interfaces liberally; prefer dependency injection |
| React/Vue/Svelte | Components should be props-driven and single-purpose; extract shared logic to hooks/composables |
| REST APIs / Microservices | Each service should own one domain; avoid shared mutable state across services |

---

## Example Triggers

- "Can you review this Python file for reusability?"  → `report` mode
- "Refactor this React component to be more reusable" → `refactor` mode
- "Is this code DRY?" → `report` mode
- "Clean up this utils.js and make it more modular" → `refactor` mode
- "Give me a code quality audit with a report first, then I'll decide if I want changes" → `report` mode

## Related Skills

- **code-knowledge**: Use to understand code structure and identify areas lacking tests. Index will need to be updated and retrained after adding tests to reflect the new structure of the codebase, and to ensure that future searches return accurate results. Be sure to load have this in context before starting.
