---
name: code-knowledge
description: A skill for understanding and modifying codebases using semantic discovery across local codebase indexing, Qdrant vector memory, and structural execution via Serena. Use this skill when you need to navigate, understand, or modify a codebase with precision and efficiency. Integrates the Qdrant MCP server (all 14 tools) as persistent semantic memory for cross-project code knowledge retrieval, pattern storage, and recommendation-based discovery.
tags: [code-knowledge, semantic-search, qdrant, vector-memory, serena, codebase-navigation]
related_skills: [mcp-server-qdrant, improve-codebase-architecture, code-compaction]
---

# Code Knowledge Skill

Orchestrates three complementary engines for code understanding and modification:
1. **Semantic Discovery** — opencode-codebase-indexer (local workspace semantic search)
2. **Persistent Memory** — Qdrant MCP server (cross-project knowledge base via all 14 tools)
3. **Structural Execution** — Serena (symbol-level precision edits and navigation)

All code in the current workspace is indexed by the codebase indexer plugin. The Qdrant MCP server provides persistent semantic memory for storing facts, patterns, architecture decisions, and learned insights across projects. Do not read entire files unless absolutely necessary.

## Engine 1: Local Semantic Discovery (opencode-codebase-index)
**Role:** The Librarian — fast spatial orientation and conceptual search within the current workspace.

- `codebase_search`: Natural language queries about code behavior ("how is auth handled?"). Returns full code content with context. Use `limit` to control result count, `directory` to scope search, `chunkType` to filter by type (function, class, etc.).
- `codebase_peek`: Lightweight lookup of file locations and metadata WITHOUT code content. Perfect for initial exploration before deciding whether to read the actual file.
- `find_similar`: Semantic similarity search — finds code that behaves similarly even if keywords differ. Use for duplicate detection and pattern discovery across the repo.

## Engine 2: Persistent Code Memory (Qdrant MCP Server)
**Role:** The Librarian with a long-term memory — stores, retrieves, and discovers code knowledge beyond the current workspace using all 14 Qdrant MCP tools.

### Why use Qdrant for code knowledge?
- **Cross-project persistence**: Knowledge learned from one project can be searched in another
- **Semantic recall**: Find related patterns by meaning, not just keywords
- **Recommendation discovery**: Given a known-good pattern, discover similar implementations elsewhere
- **Structured metadata**: Tag entries with language, module, architecture type, review status, etc.

### Storage Pattern — Using `qdrant-store`
Store code knowledge as semantic memory entries for future retrieval:

```python
# Store a learned pattern or insight
await qdrant_connector.store(Entry(
    content="This project uses JWT with refresh token rotation. Tokens are validated via middleware in src/middleware/auth.ts. Refresh tokens stored in httpOnly cookies.",
    metadata={
        "project": "api-service",
        "category": "authentication",
        "type": "architecture-decision",
        "language": "typescript",
        "source": "codebase-analysis"
    }
))

# Store a code pattern with source location
await qdrant_connector.store(Entry(
    content="Rate limiting uses a sliding window counter stored in Redis. Implemented as an Express middleware factory pattern in lib/rate-limiter.ts.",
    metadata={
        "project": "api-service",
        "category": "middleware",
        "type": "code-pattern",
        "language": "typescript",
        "file": "lib/rate-limiter.ts",
        "lines": "14-67"
    }
))

# Store a bug fix or lesson learned
await qdrant_connector.store(Entry(
    content="TypeScript build failed with TS5101 when baseUrl was deprecated. Fix: switched to path mappings in tsconfig.json and removed baseUrl from compilerOptions.",
    metadata={
        "category": "build-troubleshooting",
        "type": "bug-fix",
        "severity": "high",
        "tags": ["typescript", "tsconfig", "ts5101"]
    }
))
```

### Semantic Retrieval — Using `qdrant-find`
Search stored code knowledge by meaning, with optional filtering:

```python
# Find authentication patterns across all projects
results = await qdrant_connector.search(
    query="authentication middleware token validation",
    limit=10,
    filter_payload={"must": [{"key": "category", "match": {"value": "authentication"}}]}
)

# Find bug fixes matching current problem description
bugs = await qdrant_connector.search(
    query="build failing with deprecated baseUrl configuration",
    limit=5,
    score_threshold=0.4  # lower threshold for broader recall
)

# Find TypeScript-specific code patterns
ts_patterns = await qdrant_connector.search(
    "typescript type safety generics interfaces",
    filter_payload={
        "must": [
            {"key": "language", "match": {"value": "typescript"}},
            {"key": "type", "match": {"value": "code-pattern"}}
        ]
    }
)
```

### Recommendation-Based Discovery — Using `qdrant-recommend`
Given a known-good code pattern, discover similar implementations:

```python
# Find authentication implementations similar to the current project's pattern
similar_auth = await qdrant_connector.recommend(
    collection_name="code-knowledge",
    positive=["uuid-known-auth-pattern"],     # known good auth implementation
    negative=["uuid-weak-auth-pattern"],       # known weak auth (to avoid)
    limit=8,
    score_threshold=0.6,
    with_payload=True
)

# Discover refactoring candidates — find code similar to a deprecated pattern
deprecated_patterns = await qdrant_connector.recommend(
    collection_name="code-knowledge",
    positive=["uuid-deprecated-pattern-id"],
    query_filter={"must": [{"key": "language", "match": {"value": "typescript"}}]},
    limit=10,
    with_payload=True
)
```

### Knowledge Base Maintenance
Keep the stored knowledge base clean and organized:

```python
# Audit: how many entries per category?
for category in ["authentication", "database", "testing", "build-troubleshooting"]:
    count = await qdrant_connector.count_points("code-knowledge",
        query_filter={"must": [{"key": "category", "match": {"value": category}}]})
    print(f"{category}: {count}")

# Update metadata — mark entries as verified or deprecated
await qdrant_connector.update_points("code-knowledge", [
    {"id": "uuid-entry-1", "payload": {"verified": True, "reviewed_at": "2026-05-21"}},
    {"id": "uuid-old-entry", "payload": {"deprecated": True}}
])

# Batch cleanup — remove outdated entries across multiple categories
await qdrant_connector.batch_update("code-knowledge", [
    {"operation_type": "set_payload", "payload": {"cleanup_date": "2026-05-21"},
     "points": ["uuid-stale-1", "uuid-stale-2"]}
])

# Browse stored knowledge for context
entries = await qdrant_connector.list_points(
    "code-knowledge", limit=50, with_payload=True,
    query_filter={"must": [{"key": "category", "match": {"value": "testing"}}]}
)
```

### Cross-Engine Integration Strategy

Use Qdrant for **persistent cross-project knowledge** and the codebase indexer for **real-time workspace understanding**:

| Use case | Preferred engine | Why |
|----------|-----------------|-----|
| Search current project source code | `codebase_search` + `codebase_peek` | Instant, no setup needed |
| Find cross-project patterns | `qdrant-find` | Knowledge persists beyond one session |
| "I learned this fix once, find it again" | `qdrant-recommend` | Semantic similarity from examples |
| Understand current architecture | Serena + codebase_peek | Precise symbol-level navigation |
| Track lessons across sessions | `qdrant-store` | Durable memory that survives project changes |
| Batch-tag learned patterns | `qdrant-batch-update` | Efficient bulk updates |

### Qdrant MCP Collection Strategy for Code Knowledge

Organize knowledge into domain-specific collections:
- **`code-knowledge`** — general code patterns, architecture decisions, bug fixes
- **`project-contexts`** — project overviews and setup notes
- **`review-learnings`** — code review feedback and architectural preferences

Each collection can have different metadata schemas. Always store with rich `metadata` payload (language, category, type, tags) to enable filtered retrieval later.

## Engine 3: Structural Execution (Serena)
**Role:** The Architect — surgical precision and symbol-level reasoning for edits.

- `find_symbol`: Jump to exact definitions of Classes, Functions, Types, etc. Use when you know the identifier name.
- `find_referencing_symbols`: Map the "blast radius" of a change by finding all callers/references. Essential before any refactoring or rename.
- `get_symbols_overview`: Understand file/class structure without reading the whole file. Shows all symbols and their types/positions.
- `rename_symbol`: Perform AST-safe renames across the entire codebase atomically. Use for systematic renaming to maintain consistency.

## Orchestration Protocol (The "Find-then-Fix" Flow)

### Phase 1: Discover & Understand
1. **Scan workspace**: Use `codebase_peek` on key directories to get file layout overview.
2. **Semantic search**: Use `codebase_search` with natural language queries for behavior understanding.
3. **Check persistent memory**: Query `qdrant-find` and `qdrant-recommend` for cross-project knowledge, past lessons, or related patterns.
4. **Structural mapping**: Use Serena's `get_symbols_overview` on key files to understand architecture.

### Phase 2: Plan & Trace Dependencies
1. **Symbol lookup**: Use `find_symbol` for exact definitions of relevant identifiers.
2. **Blast radius analysis**: Use `find_referencing_symbols` to map all callers and dependencies of any symbol you plan to modify.
3. **Recommendation check**: If modifying a known pattern, use `qdrant-recommend` to see how similar patterns are handled elsewhere for consistency.

### Phase 3: Execute with Precision
1. **Apply changes** via Serena's `rename_symbol` (for renames) or `ast_grep_replace` (for pattern-based edits).
2. **Verify** using Serena's `find_referencing_symbols` post-edit to confirm no missed references.
3. **Learn & store**: After completing the task, use `qdrant-store` to record key insights, patterns discovered, or fixes applied for future retrieval.

## Token Efficiency Rules
- **Rule 1**: Never read a whole file if `get_symbols_overview` provides enough context.
- **Rule 2**: Use `codebase_peek` for initial exploration to keep the context window lean.
- **Rule 3**: Rely on Serena for symbol lookups to avoid hallucinated signatures.
- **Rule 4**: Use Qdrant MCP tools (store/find/recommend) for cross-project memory — don't re-read files from other projects you've worked with before.
- **Rule 5**: Store learnings via `qdrant-store` so future sessions can retrieve them via `qdrant-find` or `qdrant-recommend` instead of re-analyzing code.

## Known Build Pitfalls
See `references/typescript-build-troubleshooting.md` for common TypeScript build issues (TS5101 baseUrl deprecation, dynamic JSX components, .gitignore directory conflicts). Also stored in Qdrant memory via `qdrant-store(category="build-troubleshooting")`.

## When to Use Each Tool

| Task | Tool | Engine |
|------|------|--------|
| "How is feature X implemented?" | `codebase_search` | Local semantic |
| "Find files containing Y" | `codebase_peek` | Local semantic |
| "Find similar code patterns" | `find_similar` | Local semantic |
| "Jump to definition of Z" | `find_symbol` | Serena structural |
| "Show all callers of F" | `find_referencing_symbols` | Serena structural |
| "What's in this file without reading it?" | `get_symbols_overview` | Serena structural |
| "Rename identifier across repo" | `rename_symbol` | Serena structural |
| "Remember this pattern for later" | `qdrant-store` | Qdrant persistent memory |
| "Find what I learned about X before" | `qdrant-find` | Qdrant persistent memory |
| "Show me similar patterns to this one" | `qdrant-recommend` | Qdrant persistent memory |
| "Batch update project metadata" | `qdrant-batch-update` | Qdrant persistent memory |