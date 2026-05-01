---
name: code-knowledge
description: A skill for understanding and modifying codebases using a combination of semantic discovery and structural execution. Use this skill when you need to navigate, understand, or modify a codebase with precision and efficiency.
---

# Code Knowledge Skill 

Orchestrates semantic discovery (opencode-codebase-indexer) and structural execution (Serena).

## Prerequisites
- Access to the codebase indexer plugin (opencode-codebase-index) for semantic search.
- Access to Serena for structural code navigation and edits.

## 1. Discovery Engine: opencode-codebase-index
**Role:** The Librarian. Use for spatial orientation and conceptual search.
- `codebase_search`: For natural language queries (e.g., "how is auth handled?").
- `codebase_peek`: To find file locations without consuming tokens for code content.
- `find_similar`: To find patterns or duplicate logic across the repo.

## 2. Structural Engine: Serena
**Role:** The Architect. Use for surgical precision and symbol reasoning.
- `find_symbol`: Jump to exact definitions (Class/Function/Type).
- `find_referencing_symbols`: Map the "blast radius" of a change by finding all callers.
- `get_symbols_overview`: Understand structure without reading the whole file.
- `rename_symbol`: Perform AST-safe renames across the entire codebase.

## 3. Orchestration Protocol (The "Find-then-Fix" Flow)
1. **LOCATE**: Use `codebase_peek` to identify target files based on intent.
2. **MAP**: Use Serena's `get_symbols_overview` to understand the architecture.
3. **TRACE**: Use Serena's `find_referencing_symbols` to check dependencies.
4. **EXECUTE**: Apply edits via Serena to maintain semantic integrity.

## 4. Token Efficiency Rules
- **Rule 1**: Never `cat` a whole file if `get_symbols_overview` provides enough context.
- **Rule 2**: Use `codebase_peek` for initial exploration to keep the context window lean.
- **Rule 3**: Rely on Serena for symbol lookups to avoid hallucinated signatures.
