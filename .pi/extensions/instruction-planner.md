# Instruction Planner Extension

A pi extension that detects important, complex user instructions and automatically delegates them to a planning subagent. The resulting structured plan is injected into the LLM context before the main agent starts processing, giving it organized, actionable guidance instead of raw user text.

## How It Works

### Detection Heuristics
The extension scans each user message against 10+ pattern groups:

| Category | Examples |
|----------|----------|
| **Planning structure** | `Plan:`, numbered steps (`1.`), phases/milestones |
| **Architectural language** | "architect the system", "design framework", "build from scratch" |
| **Scope-changing verbs** | refactor, migrate, restructure, redesign, rewrite |
| **Multi-step complexity** | "first need... then we...", step1, phase2 chains |
| **Priority markers** | "important: implement...", "critical: must have..." |
| **Multi-part requests** | "also require", "in addition need", "another feature" |
| **Long-form delegation** | Multi-line build/create/implement requests |

### Flow

```
User types: "I want to build a new auth system with OAuth, JWT refresh tokens, and role-based access"
        │
        ▼  (input event fires)
Detect → isImportantInstruction("...") → TRUE
        │
        ├──► Spinner shown: "🧠 planning..."
        └──► Subagent launched async (non-blocking)
                │
        User's original turn proceeds normally with raw text
                │
        ▼  (before_agent_start on next turn)
Inject structured plan into context as [PLANNED INSTRUCTIONS] block
Agent now has organized steps to execute
```

### Output Format
The planner produces:
1. One-sentence intent summary
2. Numbered atomic action steps with file/component targets
3. Risk/dependency notes
4. Recommended execution order

## Installation

Drop the `.ts` file into any of these locations:

- **Project-local**: `<project>/.pi/extensions/instruction-planner.ts`
- **Global**: `~/.pi/agent/extensions/instruction-planner.ts` (requires writable fs)

Then restart pi or run `/reload`.

## Configuration

No config needed — works silently out of the box. The planner runs automatically when important instructions are detected. Status indicator:

| Status | Indicator | Meaning |
|--------|-----------|---------|
| `🧠 planning...` | warning yellow | Subagent running |
| `✓ planned` | success green | Plan ready, will inject next turn |
| `plan err` | error red | Planner failed (check stderr) |
| _(none)_ | — | Idle / no important instructions detected |

## Troubleshooting

- **Planner not triggering**: Check if your message matches the heuristic patterns. Short/simple messages skip planning intentionally to avoid overhead.
- **Slow planner**: The subagent has a 30s timeout. If it's timing out, try simplifying the request or use `/reload` after fixing model config issues.
- **Plan not injected**: Timing issue — if planning takes longer than one agent turn, the plan is injected on the next `before_agent_start`. You'll see `[⏳ Planning in progress]` for intermediate turns.
