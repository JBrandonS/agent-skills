---
name: mcp-server-qdrant
description: >
  Comprehensive guide for working with mcp-server-qdrant, an MCP server that provides
  semantic memory capabilities on top of the Qdrant vector search engine. Covers all 14
  tools across collection management, point operations, batch updates, and recommendations.
  Use when building, debugging, or extending an mcp-server-qdrant project, or when
  working with Qdrant MCP tools in Claude Code. Trigger on "mcp server qdrant", "qdrant
  tools", "vector database query", "semantic search", or any task involving this project.
tags: [mcp, qdrant, vector-search, embedding, semantic-memory, mcp-server]
related_skills: [test-driven-development, code-coverage, software-design-patterns]
---

# MCP Server Qdrant Skill

## Purpose

This skill provides comprehensive guidance for working with `mcp-server-qdrant`, a Model Context Protocol (MCP) server that wraps the Qdrant vector search engine. It covers all 14 tools: collection management, point CRUD operations, batch updates, filtering, and semantic recommendations.

**Core principle:** Qdrant uses named vectors with UUID-format IDs in local mode. Always verify vector naming conventions and use proper ID formats when testing or debugging.

## Architecture Overview

```
MCP Client (Claude Code, Cursor, etc.)
    │
    ▼
mcp_server.py  ← FastMCP tool registrations (14 tools)
    │  async def tool_func(ctx, params...) -> result
    │  uses Annotated[str, Field(description=...)] for MCP schema
    │  calls self.qdrant_connector.method()
    ▼
qdrant.py      ← QdrantConnector class
    │  wraps AsyncQdrantClient methods
    │  returns plain Python types (dict/list/str/int)
    │  handles named-vector auto-detection
    ▼
qdrant_client.AsyncQdrantClient  ← Official Qdrant SDK v1.12+
```

### Key Conventions
- **Tool names**: `qdrant-{action}` (e.g., `qdrant-store`, `qdrant-find`)
- **Connector methods**: snake_case (e.g., `store()`, `search()`)
- **Vector naming**: Named vectors use `{vector_name: [values]}` format. Vector name from FastEmbed is `f"fast-{model_name}"` (e.g., `"fast-all-minilm-l6-v2"`)
- **Point IDs**: Local Qdrant requires UUID-format IDs (`uuid.uuid4()` → 36 chars with dashes), NOT hex strings

## Tool Categories & Quick Reference

### Collection Management (6 tools)
| Tool | Mutates? | Description |
|------|----------|-------------|
| `qdrant-store` | Yes | Store text with auto-embedding |
| `qdrant-find` | No | Semantic search |
| `qdrant-list-collections` | No | List all collection names |
| `qdrant-get-collection-info` | No | Collection stats + config |
| `qdrant-create-collection` | Yes | Create with vector size + distance |
| `qdrant-update-collection` | Yes | Optimizer/replication settings |
| `qdrant-delete-collection` | Yes | Delete (irreversible) |

### Point Listing & Retrieval (3 tools)
| Tool | Mutates? | Description |
|------|----------|-------------|
| `qdrant-list-points` | No | Paginated listing with filters |
| `qdrant-count-points` | No | Filtered point count |
| `qdrant-get-point` | No | Retrieve by ID(s) |

### Point Update & Delete (5 tools)
| Tool | Mutates? | Description |
|------|----------|-------------|
| `qdrant-update-points` | Yes | Set payload on specific points |
| `qdrant-delete-points` | Yes | Delete points by ID |
| `qdrant-update-vectors` | Yes | Update vectors on specific points |
| `qdrant-delete-vectors` | Yes | Remove named vectors from points |
| `qdrant-batch-update` | Yes | Multiple operations in one request |

### Recommendations (1 tool)
| Tool | Mutates? | Description |
|------|----------|-------------|
| `qdrant-recommend` | No | Find similar to positive, away from negative examples |

## Common Workflows

### 1. Store & Search Pattern (Core Memory Flow)
```python
# Store a memory entry
await qdrant_connector.store(Entry(content="The capital of France is Paris", metadata={"category": "geography"}))

# Find relevant memories
results = await qdrant_connector.search("European capitals", limit=5)
```
**How it works:** `store()` auto-generates an embedding via the embedding provider (FastEmbed), wraps it as `{vector_name: [values]}` for named-vector collections, and upserts. `search()` embeds the query and performs vector similarity search.

### 2. Collection Lifecycle
```python
# List existing collections
collections = await qdrant_connector.list_collections()

# Create a new collection explicitly (for custom vector sizes/distances)
await qdrant_connector.create_collection("my-collection", vector_size=384, distance="Cosine")

# Get stats
info = await qdrant_connector.get_collection_info("my-collection")
print(f"Points: {info['points_count']}, Status: {info['status']}")

# Update settings (server mode only)
await qdrant_connector.update_collection("my-collection", optimizer_config={"indexing_threshold": 10000})

# Clean up
await qdrant_connector.delete_collection("my-collection")
```
**Note:** When using `store()`/`find()`, collections are auto-created via `_ensure_collection_exists()` with the embedding provider's vector name and size. Explicit `create_collection()` is for non-embedding use cases (raw vectors, custom configs).

### 3. Point Operations
```python
# List all points (paginated)
result = await qdrant_connector.list_points("my-collection", limit=20, with_payload=True)
if result["next_offset"]:
    more = await qdrant_connector.list_points("my-collection", limit=20, offset=result["next_offset"])

# Count points
total = await qdrant_connector.count_points("my-collection")

# Get specific points by ID
points = await qdrant_connector.get_point("my-collection", ids=["uuid-1", "uuid-2"], with_vector=True)

# Update payload on a point
await qdrant_connector.update_points("my-collection", [{"id": "uuid-1", "payload": {"tag": "important"}}])

# Update vector on a point
await qdrant_connector.update_vectors("my-collection", [{"id": "uuid-1", "vector": [0.1] * 384}])

# Delete points
await qdrant_connector.delete_points("my-collection", ["uuid-1", "uuid-2"])

# Delete vectors (keep payload)
await qdrant_connector.delete_vectors("my-collection", ["uuid-1"], vector_names=["fast-all-minilm-l6-v2"])
```

### 4. Batch Operations
```python
await qdrant_connector.batch_update("my-collection", [
    {"operation_type": "upsert", "points": [{"id": "a", "vector": [...], "payload": {...}}]},
    {"operation_type": "set_payload", "payload": {"batch": True}, "points": ["a", "b"]},
    {"operation_type": "delete_points", "ids": ["c"]},
])
```

### 5. Recommendations (Look-alike Search)
```python
# Find points similar to these examples
results = await qdrant_connector.recommend(
    "my-collection",
    positive=["uuid-good1", "uuid-good2"],
    negative=["uuid-bad1"],
    limit=10,
    score_threshold=0.5,
)
```
**Important:** Recommendations need at least 2 points in the collection — with only 1 point, no similar points exist to recommend.

## Filter Patterns

Filters use Qdrant's filter DSL (`models.Filter`):

```python
# Must condition (all must match)
filter_obj = models.Filter(must=[
    models.FieldCondition(key="category", match=models.MatchValue(value="tech"))
])

# Must-not condition (none must match)
filter_obj = models.Filter(must_not=[
    models.FieldCondition(key="deprecated", match=models.MatchBoolean(value=True))
])

# Bool filter (combine conditions)
filter_obj = models.Filter(
    should=[
        models.FieldCondition(key="tag", match=models.MatchValue(value="important")),
        models.Range(key="score", gte=0.8),
    ],
    must_not=[models.FieldCondition(key="draft", match=models.MatchBoolean(value=True))]
)
```

**Payload indexing requirement (server mode only):** Filtered queries on payload fields require prior indexing via `create_payload_index()`. Local Qdrant does not support payload indexes — filtering without index may return empty results.

## Key Bug Fixes & Gotchas

### Named Vectors
Collections auto-created via `_ensure_collection_exists()` use named vectors with format `{vector_name: [values]}`. Always wrap vector data appropriately:
```python
# Wrong for named-vector collections:
{"id": point_id, "vector": [0.1, 0.2, ...]}

# Correct:
{"id": point_id, "vector": {"fast-all-minilm-l6-v2": [0.1, 0.2, ...]}}
```

### Point IDs in Local Mode
Local Qdrant (`:memory:` or local path) rejects hex string IDs — must use full UUID format:
```python
# Wrong (32-char hex): str(uuid.uuid4().hex) → "abc123..."
# Correct (36-char with dashes): str(uuid.uuid4()) → "abc123-def456-..."
```

### Delete Vectors API Change (Qdrant Client v1.12+)
The `points_selector=models.PointIdsList(...)` pattern was deprecated in favor of:
```python
# Old (broken): points_selector=models.PointsSelector(points=ids)
# New: delete_vectors(collection_name, ids, vectors=[name], points=ids)
```

### Recommend Auto-Detects Vector Name
The `recommend()` method auto-detects the `using` vector name from collection config when not explicitly provided. Empty collections are handled with an early return of `[]`.

## Testing Patterns

All tests follow TDD workflow:
1. Create `QdrantConnector(url=":memory:", collection_name=f"test_{uuid}")` fixture
2. Store data before querying (collections auto-created)
3. Use UUID-format point IDs
4. For named-vector collections, wrap assertions to handle `{name: [values]}` dict format
5. Skip payload filter tests for local mode with `pytest.skip("...")`
6. Recommend tests need 2+ points in collection

**Test run:** `uv run pytest tests/ -v --tb=short`

## Environment Variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `QDRANT_URL` | Remote Qdrant server URL | None (use local) |
| `QDRANT_LOCAL_PATH` | Local DB path (alternative to URL) | `:memory:` if no URL or local path set |
| `QDRANT_API_KEY` | API key for cloud/server mode | None |
| `COLLECTION_NAME` | Default collection name | None |
| `EMBEDDING_PROVIDER` | Embedding backend | `fastembed` |
| `EMBEDDING_MODEL` | FastEmbed model to use | `sentence-transformers/all-MiniLM-L6-v2` |
| `QDRANT_SEARCH_LIMIT` | Default search result count | `10` |
| `QDRANT_READ_ONLY` | Disable all mutating tools | `false` |
| `QDRANT_FILTERABLE_FIELDS` | Comma-separated payload fields to index | `[]` |

## Development Commands

```bash
# Run tests
uv run pytest tests/ -v --tb=short

# Run dev server with MCP inspector
COLLECTION_NAME=mcp-dev fastmcp dev src/mcp_server_qdrant/server.py

# Build Docker image
docker build -t mcp-server-qdrant .

# Run with uvx (no install needed)
QDRANT_URL="http://localhost:6333" uvx mcp-server-qdrant --transport sse
```

## Common Error Patterns

### "Payload indexes have no effect in the local Qdrant"
Filtered queries on payload fields won't work reliably with `:memory:` or local DB. Use a real Qdrant server for filtered queries, or skip tests in local mode.

### Empty recommend results
Requires at least 2 points in the collection. Single-point collections return `[]` because there are no "similar" points.

### Vector dimension mismatch
When creating a collection manually via `qdrant-create-collection`, ensure `vector_size` matches your embedding model (e.g., 384 for all-MiniLM-L6-v2, 768 for larger models).

### 304 Not Modified errors in tests
Related to Qdrant client caching. Run tests with `--disable-warnings` or upgrade qdrant-client if persistent.
