---
name: oh-my-opencode-slim
description: "Specialist-agent orchestration patterns from oh-my-opencode-slim. Use when delegating coding tasks, reviewing architecture, researching codebases, implementing bounded changes, or running multi-model consensus. Provides the Explorer/Librarian/Oracle/Designer/Fixer/Council/Observer agent model with full delegation rules and prompts."
version: 1.0.0
author: Hermes Agent / alvinunreal
license: MIT
metadata:
  hermes:
    tags: [Agent-Architecture, Delegation, Specialist-Agents, OpenCode, Code-Review, Research]
    related_skills: [opencode, code-knowledge, code-reusability, debugging-hermes-tui-commands]
---

# oh-my-opencode-slim: Specialist-Agent Orchestration

Apply the oh-my-opencode-slim specialist-agent model to Hermes Agent workflows. This skill teaches when and how to delegate tasks to domain-specialist subagents, mirroring the patterns used in [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim).

## When to Use

- You're about to start a complex coding task that could benefit from specialist delegation
- The user asks for code review, architecture analysis, or multi-model consensus
- You need to research a codebase or external library before implementing
- You want to structure work using the Understand → Parallelize → Execute → Verify workflow
- You're using OpenCode with the oh-my-opencode-slim plugin installed

## The Specialist-Agent Model

The core idea: **don't try to do everything yourself — delegate to specialists optimized for specific tasks.** Each specialist has defined capabilities, constraints, and when-to-use rules.

```
┌─────────────┐     delegate      ┌───────────┐
│  Orchestrator│──────────────────▶│  Explorer  │  ← codebase navigation
│  (you)       │◀──────────────────│  Librarian │  ← external docs research
│              │──────────────────▶│  Oracle    │  ← architecture review
│              │──────────────────▶│  Designer  │  ← UI/UX implementation
│              │──────────────────▶│  Fixer     │  → fast execution
│              │──────────────────▶│  Council   │  → multi-LLM consensus
│              │──────────────────▶│  Observer  │  → visual analysis
└─────────────┘                   └───────────┘
```

## Delegation Rules (Which Agent to Use)

| Request Type | Agent | Why |
|-------------|-------|-----|
| "Where is X in the codebase?" / "Find Y" | `@explorer` | 2x faster search, parallel grep/glob/ast queries |
| "How does this library work?" / API docs | `@librarian` | 10x better at finding up-to-date docs via MCPs |
| Architecture review / complex debugging | `@oracle` | 5x better decision maker, YAGNI enforcement |
| UI/UX implementation or polish | `@designer` | 10x better visual judgment, Tailwind-first |
| Bounded implementation / test writing | `@fixer` | 2x faster code edits, receives complete context |
| Multi-model consensus needed | `@council` | Runs multiple models in parallel, synthesizes verdict |
| Analyze screenshot/image/PDF | `@observer` | Isolates visual bytes from main context window |

### When NOT to Delegate

- **Explaining > doing**: If explaining the task to a specialist takes longer than doing it yourself → do it yourself
- **Single small change** (<20 lines, one file) → handle directly
- **Routine decisions** you're confident about → handle directly
- **Sequential dependencies** that would block parallelization → handle directly

### Parallel Delegation Patterns

- Multiple `@explorer` searches across different domains in parallel
- `@explorer` + `@librarian` research in parallel (codebase search + external docs)
- Multiple `@fixer` instances for faster, scoped implementation (split by folder/module)
- `@observer` + `@explorer` in parallel (visual analysis + code search)

## The Workflow Protocol

Always follow this sequence:

1. **Understand** — What is the task? What specialists are needed?
2. **Parallelize** — Choose the best parallelized path based on delegation rules
3. **Session Reuse** — Recall if any child sessions can be reused (short aliases)
4. **Execute** — Launch specialists, collect results
5. **Verify** — Confirm outcomes match expectations

## Specialist Agent Definitions

### Explorer (`@explorer`) — Codebase Navigation

**Role**: Fast codebase search specialist. Answers "Where is X?", "Find Y", "Which file has Z".

**When to delegate**: Need to discover what exists before planning, parallel searches speed discovery, broad/uncertain scope.

**When NOT to delegate**: Know the path and need actual content, need full file anyway, single specific lookup, about to edit the file.

**Tools**: `grep` (text/regex), `ast_grep_search` (structural patterns), `glob` (file discovery)

**Output Format**:
```
<results>
<files>
- /path/to/file.ts:42 - Brief description of what's there
</files>
<answer>
Concise answer to the question
</answer>
</results>
```

### Librarian (`@librarian`) — External Research

**Role**: Authoritative source for current library docs and API references.

**When to delegate**: Libraries with frequent API changes (React, Next.js, AI SDKs), complex APIs needing official examples, version-specific behavior matters, unfamiliar library, edge cases or advanced features.

**When NOT to delegate**: Standard usage you're confident about, simple stable APIs, general programming knowledge, info already in conversation, built-in language features.

**Rule of thumb**: "How does this library work?" → `@librarian`. "How does programming work?" → yourself.

**Tools**: MCPs — `websearch`, `context7` (official docs), `grep_app` (GitHub code search)

### Oracle (`@oracle`) — Strategic Advisor & Code Reviewer

**Role**: High-IQ debugging, architecture decisions, code review, simplification, YAGNI enforcement.

**When to delegate**: Major architectural decisions with long-term impact, problems persisting after 2+ fix attempts, high-risk multi-system refactors, costly trade-offs (performance vs maintainability), complex debugging with unclear root cause, security/scalability/data integrity decisions, genuinely uncertain and cost of wrong choice is high, when a workflow calls for a reviewer subagent, code needs simplification or YAGNI scrutiny.

**When NOT to delegate**: Routine decisions you're confident about, first bug fix attempt, straightforward trade-offs, tactical "how" vs strategic "should", time-sensitive good-enough decisions, quick research/testing can answer.

**Rule of thumb**: Need senior architect review? → `@oracle`. Need code review or simplification? → `@oracle`. Just do it and PR? → yourself.

**Constraints**: READ-ONLY — advises, doesn't implement. Focus on strategy, not execution.

### Designer (`@designer`) — UI/UX Implementation

**Role**: Frontend UI/UX specialist who creates and reviews intentional, polished experiences.

**When to delegate**: User-facing interfaces needing polish, responsive layouts, UX-critical components (forms, nav, dashboards), visual consistency systems, animations/micro-interactions, landing/marketing pages, refining functional→delightful, reviewing existing UI/UX quality.

**When NOT to delegate**: Backend/logic with no visual component, quick prototypes where design doesn't matter yet.

**Rule of thumb**: Users see it and polish matters? → `@designer`. Headless/functional? → yourself.

**Design Principles**:
- **Typography**: Distinctive fonts, avoid generic defaults (Arial, Inter), pair display with body fonts
- **Color & Theme**: Cohesive aesthetic with sharp accents > timid evenly-distributed palettes
- **Motion & Interaction**: High-impact moments (staggered reveals, scroll-triggers), one well-timed animation > scattered micro-interactions
- **Spatial Composition**: Break conventions — asymmetry, overlap, diagonal flow, generous negative space OR controlled density
- **Styling**: Default to Tailwind CSS utilities; custom CSS only when vision requires it
- **Match Vision to Execution**: Maximalist → elaborate implementation; Minimalist → restraint and precision

### Fixer (`@fixer`) — Fast Implementation

**Role**: Execute code changes efficiently. Receives complete context from research agents and clear task specifications.

**When to delegate**: Bounded implementation work, writing/updating tests, tasks touching test files/fixtures/mocks/test helpers, parallelization benefits (multiple folders/files), splitting work per folder/module.

**When NOT to delegate**: Needs discovery/research/decisions, single small change (<20 lines, one file), unclear requirements needing iteration, explaining to fixer > doing it, tight integration with current work, sequential dependencies.

**Constraints**:
- NO external research (no websearch, context7, grep_app)
- NO delegation or spawning subagents
- No multi-step research/planning; minimal execution sequence ok
- If context is insufficient: use grep/glob/read directly — do not delegate

**Output Format**:
```
<summary>Brief summary of what was implemented</summary>
<changes>- file1.ts: Changed X to Y</changes>
<verification>- Tests passed: [yes/no/skip reason]</verification>
```

### Council (`@council`) — Multi-LLM Consensus

**Role**: Runs several models in parallel, compares answers, resolves disagreements, produces a final synthesized answer.

**When to delegate**: Critical decisions needing multiple independent perspectives, high-stakes architectural/security/data-integrity choices, ambiguous problems where disagreement is useful signal, want confidence beyond a single model, user explicitly asks for council/consensus/multiple opinions.

**When NOT to delegate**: Straightforward tasks you're confident about, speed matters more than confidence, routine implementation/debugging, a single specialist is clearly the right tool, only need current docs/search/code review rather than multi-model consensus.

**Stats**: 3x slower, 3x+ cost — use sparingly. Intentionally not auto-delegated.

### Observer (`@observer`) — Visual Analysis

**Role**: Interprets images, screenshots, PDFs, and diagrams. Returns structured observations without loading raw file bytes into main context.

**When to delegate**: Need to analyze a multimedia file, extract information from visual content.

**When NOT to delegate**: Plain text files that Read can handle directly, files that need editing afterward (need literal content from Read).

**Rule of thumb**: Even if your model supports vision, delegate visual analysis — it isolates large image/PDF bytes from context window, returning only concise structured text.

**Important**: Always include the **full file path** when delegating to Observer. Example: "Analyze the screenshot at `/path/to/file.png` — describe the UI elements and error messages."

## Integration with OpenCode

If OpenCode is installed with the oh-my-opencode-slim plugin, you can leverage these specialists directly in OpenCode sessions.

### Using Specialists in OpenCode

When the plugin is loaded, OpenCode agents become available as tab-switchable specialists:

```
# In OpenCode TUI, press Tab to switch between agents
# Or use --agent flag for one-shot tasks:

opencode run 'Find all authentication-related files and summarize patterns' --agent explorer
opencode run 'Review this codebase for architectural issues' --agent oracle
opencode run 'Implement the new payment endpoint' --agent fixer
```

### Running Council Sessions in OpenCode

```
# Multi-model consensus via OpenCode CLI
opencode run 'Compare these two database migration strategies: A) dual-write with shadow reads, B) backfill with feature flag. Which is safer?'
# Then use the council agent or @council command in the session
```

### Session Reuse Aliases

OpenCode with oh-my-opencode-slim creates short aliases for recent child sessions. Reuse them instead of starting over:

```
# Check available aliases
opencode session list

# Resume a specific child session
opencode -s ses_abc123
```

## Tool Selection Guide

| Task | Best Tool | Why |
|------|-----------|-----|
| Text/regex search in files | `grep` | Fast, ripgrep-backed |
| Structural code patterns | `ast_grep_search` | Understands code structure (arrows returning JSX, etc.) |
| Code refactoring | `ast_grep_replace` | AST-aware with dry-run support |
| Web content extraction | `webfetch` | Prefers `llms.txt`, extracts main content from HTML |
| Official library docs | `context7` MCP | Up-to-date documentation |
| GitHub code examples | `grep_app` MCP | Search real production code |
| General web search | `websearch` MCP | Real-time web results |

## MCP Permission Model

Control which MCPs each agent can use. Default permissions:

| Agent | Default MCPs |
|-------|-------------|
| Orchestrator | All except `context7` |
| Librarian | `websearch`, `context7`, `grep_app` |
| Designer/Oracle/Explorer/Fixer/Councillor | None |

Permission syntax in config:
- `["*"]` = all MCPs
- `["*", "!context7"]` = all except context7
- `["websearch", "context7"]` = only these
- `[]` = no MCPs

## Custom Agent Support

Define custom agents beyond the built-in set:

```jsonc
{
  "presets": {
    "my-preset": {
      "qa-auditor": {
        "model": "openai/gpt-5.4-mini",
        "prompt": "You are a code quality auditor...",
        "displayName": "@qa"
      }
    }
  }
}
```

Custom agents:
- Must use safe names: `^[a-z][a-z0-9_-]*$` and not clash with built-in names
- Default to explorer-level subagent access (can spawn `@explorer`)
- Can override with `prompt`, `displayName`, `skills`, `mcps`

## Aliases

| Alias | Maps To |
|-------|---------|
| `@explore` | `@explorer` |
| `@frontend-ui-ux-engineer` | `@designer` |

## Preset Examples

### Author's Daily Preset (OpenAI)

```jsonc
{
  "preset": "openai",
  "presets": {
    "openai": {
      "orchestrator": { "model": "openai/gpt-5.5-fast", "skills": ["*"], "mcps": ["*", "!context7"] },
      "oracle": { "model": "openai/gpt-5.5-fast", "variant": "high", "skills": [], "mcps": [] },
      "council": { "model": "openai/gpt-5.5-fast" },
      "librarian": { "model": "openai/gpt-5.3-codex-spark", "variant": "low", "skills": [], "mcps": ["websearch", "context7", "grep_app"] },
      "explorer": { "model": "openai/gpt-5.3-codex-spark", "variant": "low", "skills": [], "mcps": [] },
      "designer": { "model": "github-copilot/gemini-3.1-pro-preview", "skills": ["agent-browser"], "mcps": [] },
      "fixer": { "model": "openai/gpt-5.3-codex-spark", "variant": "low", "skills": [], "mcps": [] }
    }
  },
  "council": {
    "presets": {
      "default": {
        "alpha":  { "model": "github-copilot/claude-sonnet-4.6", "variant": "high" },
        "beta":   { "model": "github-copilot/gemini-3.1-pro-preview", "variant": "high" },
        "gamma":  { "model": "fireworks-ai/accounts/fireworks/routers/kimi-k2p5-turbo" }
      }
    }
  }
}
```

### Budget Preset (~$30/month)

Uses faster, cheaper models for most work, reserving strong models for Oracle/Council. See `docs/thirty-dollars-preset.md` in the source repo for full config.

## Pitfalls

- **Fixer cannot delegate** — if context is insufficient, use grep/glob/read directly
- **Council is expensive** — 3x slower, 3x+ cost. Use only when multiple perspectives add value
- **Observer is opt-in** — requires a vision-capable model; saves context tokens by isolating image/PDF bytes
- **Session reuse** — child sessions get short aliases so they can be reused instead of starting over
- **Phase reminder** — always follow: Understand → choose best parallelized path → recall session reuse rules → execute → verify
- **apply-patch rescue** — stale patches are intercepted and rewritten; out-of-bounds paths are blocked

## Verification

Smoke test the delegation logic:

```
# Test: Can you correctly route this task?
"Find all React components that handle form submission in src/components/ and check if they use the new validation library from PR #42"

Expected routing: @explorer (codebase search) + @librarian (validation library docs) in parallel
NOT: @fixer (this is research, not implementation)
NOT: @oracle (no architectural decision needed yet)
```

## Rules

1. Prefer delegation to specialists when it provides net efficiency gains
2. Route UI/UX validation → `@designer`
3. Route code review/simplification → `@oracle`
4. Route test writing → `@fixer`
5. Route visual/media analysis → `@observer`
6. If a request spans multiple lanes, delegate only the lanes that add clear value
7. Never delegate when explaining the task takes longer than doing it yourself
