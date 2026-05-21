---
name: mcp-server-qdrant
description: >
  Comprehensive guide for working with mcp-server-qdrant, an MCP server that provides
  semantic memory capabilities on top of the Qdrant vector search engine. Covers all 14
  tools across collection management, point operations, batch updates, filtering, scoring,
  recommendations, and look-alike discovery. Use when building, debugging, or extending
  an mcp-server-qdrant project, or when working with Qdrant MCP tools in Claude Code.
  Trigger on "mcp server qdrant", "qdrant tools", "vector database query", "semantic
  search", "recommendation API", "look-alike", or any task involving this project.
tags: [mcp, qdrant, vector-search, embedding, semantic-memory, mcp-server]
related_skills: [test-driven-development, code-coverage, software-design-patterns, qdrant-search-quality, qdrant-performance-optimization, qdrant-monitoring]
---

# MCP Server Qdrant Skill

## Purpose

This skill provides comprehensive guidance for working with `mcp-server-qdrant`, a Model Context Protocol (MCP) server that wraps the Qdrant vector search engine. It covers all 14 tools: collection management, point CRUD operations, batch updates, filtering, scoring, recommendations, and look-alike discovery.

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
    └── Embedding: FastEmbed (auto-generated on store/find)
```

### Key Conventions
- **Tool names**: `qdrant-{action}` (e.g., `qdrant-store`, `qdrant-find`)
- **Connector methods**: snake_case (e.g., `store()`, `search()`)
- **Vector naming**: Named vectors use `{vector_name: [values]}` format. Vector name from FastEmbed is `f"fast-{model_name}"` (e.g., `"fast-all-minilm-l6-v2"`)
- **Point IDs**: Local Qdrant requires UUID-format IDs (`uuid.uuid4()` → 36 chars with dashes), NOT hex strings
- **Auto-created collections**: When using `store()`/`find()`, collections are auto-created via `_ensure_collection_exists()` with the embedding provider's vector name and size. Explicit `create_collection()` is for non-embedding use cases (raw vectors, custom configs)

## All 14 Tools — Full Reference

### Collection Management (6 tools)

#### `qdrant-store`
Stores text content with auto-generated embeddings. Upserts if the point already exists.

**Use when:** Adding a new fact, document chunk, or context entry to the knowledge base.

```python
# MCP Tool call parameters:
{
    "collection_name": "my-knowledge",       # optional — uses default if none provided
    "content": "The capital of France is Paris",
    "metadata": {"category": "geography", "source": "manual"},  # optional payload
    "point_id": null                          # optional — auto-generates UUID if not provided
}

# Returns: dict with point_id and status
```

#### `qdrant-find`
Semantic search via query embedding + vector similarity. Returns ranked results by score.

**Use when:** Looking up information by meaning rather than keywords. Supports filtering and limit control.

```python
{
    "query": "European capitals",             # free-text query (auto-embedded)
    "collection_name": "my-knowledge",        # optional
    "limit": 5,                                # max results to return
    "score_threshold": 0.5,                    # minimum similarity score [0..1]
    "offset": 0,                               # pagination offset
    "filter_payload": {                        # optional filter DSL
        "must": [{"key": "category", "match": {"value": "geography"}}]
    }
}

# Returns: list of dicts with point_id, payload, score, and optionally vector
```

#### `qdrant-list-collections`
Lists all collection names in the Qdrant instance.

**Use when:** Discovering what collections exist before operating on them.

```python
{
    # No parameters
}
# Returns: list of collection name strings
```

#### `qdrant-get-collection-info`
Returns detailed collection statistics and configuration: point count, vector size, distance metric, segment info, optimizer status, HNSW config.

**Use when:** Checking collection health, debugging indexing issues, or verifying config before operations.

```python
{
    "collection_name": "my-knowledge"
}
# Returns: dict with points_count, vector_size, distance, segments, hsnw_config, optimizer_status, etc.
```

#### `qdrant-create-collection`
Creates a new collection with specified vector size and distance metric. Auto-creates only needed when using store/find; explicit creation is for non-embedding use cases or custom configs.

**Use when:** Setting up collections with specific configurations (custom vector sizes, distances) or before creating payload indexes (server mode).

```python
{
    "collection_name": "my-knowledge",
    "vector_size": 384,                       # matches embedding model dimensions
    "distance": "Cosine"                      # Cosine, Euclid, Dot, or Manhattan
}
# Returns: success status
```

#### `qdrant-update-collection`
Updates collection-level settings: optimizer thresholds, replication factor, write consistency. Server mode only (local Qdrant ignores these).

**Use when:** Tuning indexing performance, scaling replication, or adjusting write guarantees in production.

```python
{
    "collection_name": "my-knowledge",
    "optimizer_config": {                     # optional — overrides existing values
        "indexing_threshold": 10000,           # points before auto-indexing trigger
        "max_segment_size": 500,               # max vectors per segment
        "deleted_threshold": 0.2,              # delete ratio for segment flush
        "vacuum_min_vector_number": 1000       # min vectors for background cleanup
    },
    "replication_factor": 3,                   # number of shard copies (server mode)
    "write_consistency_factor": 2             # acknowledgments required (server mode)
}
# Returns: success status
```

#### `qdrant-delete-collection`
Irreversibly deletes a collection and all its data.

**Use when:** Cleaning up test collections or removing outdated knowledge bases.

```python
{
    "collection_name": "my-knowledge"
}
# Returns: success status
```

### Point Listing & Retrieval (3 tools)

#### `qdrant-list-points`
Paginated listing of all points with optional filtering. Supports payload and vector inclusion.

**Use when:** Browsing stored memories, auditing knowledge base contents, or iterating over large datasets.

```python
{
    "collection_name": "my-knowledge",
    "limit": 50,                               # max points per page (1..many)
    "offset": null,                            # start from this point for pagination
    "with_vector": false,                      # include vector data in results
    "with_payload": true,                      # include payload metadata in results
    "query_filter": {                          # optional filter DSL
        "must": [{"key": "category", "match": {"value": "geography"}}]
    }
}

# Returns: dict with points list, next_offset for continuation, total_count
```

#### `qdrant-count-points`
Returns point count for a collection, optionally filtered.

**Use when:** Quick health checks (e.g., "how many entries are in my knowledge base?") without loading all data.

```python
{
    "collection_name": "my-knowledge",
    "query_filter": null                       # optional — filter to count matching subset
}
# Returns: dict with exact point count
```

#### `qdrant-get-point`
Retrieves specific points by their IDs, with option to include vector data.

**Use when:** Fetching detailed records for display, analysis, or downstream processing after finding them via search.

```python
{
    "collection_name": "my-knowledge",
    "ids": ["uuid-1", "uuid-2"],
    "with_vector": false,                      # include vectors if needed for debugging
    "with_payload": true                       # include payload metadata
}
# Returns: list of point dicts with id, vector (optional), and payload
```

### Point Update & Delete Operations (5 tools)

#### `qdrant-update-points`
Sets or replaces payload on specific points by ID. Use to tag memories, update categories, or mark entries as deprecated.

**Use when:** Updating metadata without re-embedding content (preserves existing vector).

```python
{
    "collection_name": "my-knowledge",
    "points_list": [
        {"id": "uuid-1", "payload": {"tag": "important", "reviewed": true}},
        {"id": "uuid-2", "payload": {"deprecated": true}}
    ]
}
# Returns: success status
```

#### `qdrant-delete-points`
Deletes specific points by ID. Removes both vector and payload data.

**Use when:** Removing outdated or incorrect memories from the knowledge base.

```python
{
    "collection_name": "my-knowledge",
    "ids": ["uuid-1", "uuid-2"]               # list of UUID point IDs
}
# Returns: success status
```

#### `qdrant-update-vectors`
Replaces the vector embeddings on specific points while keeping payload intact. Use when you need to re-embed content with a different model or update embeddings manually.

**Use when:** Switching embedding models, fine-tuning vectors, or batch-reembedding without touching metadata.

```python
{
    "collection_name": "my-knowledge",
    "points": [
        {"id": "uuid-1", "vector": {"fast-all-minilm-l6-v2": [0.1] * 384}},
        {"id": "uuid-2", "vector": {"fast-all-minilm-l6-v2": [0.2] * 384}}
    ]
}
# Returns: success status
```

#### `qdrant-delete-vectors`
Removes specific named vectors from points while keeping other data (payload, other vectors). Use to clean up vector space without losing metadata.

**Use when:** Removing an embedding model from a point, freeing storage, or switching between models incrementally.

```python
{
    "collection_name": "my-knowledge",
    "ids": ["uuid-1"],
    "vector_names": ["fast-all-minilm-l6-v2"]  # specific vector names to remove
}
# Returns: success status
```

#### `qdrant-batch-update`
Executes multiple operations (upsert, delete, set_payload, update_vectors) in a single request. Most efficient for bulk changes across many points.

**Use when:** Migrating data between models, bulk tagging entries, cleaning up stale data, or any multi-point operation that would otherwise require many individual tool calls.

```python
{
    "collection_name": "my-knowledge",
    "operations": [
        {
            "operation_type": "upsert",
            "points": [
                {"id": str(uuid4()), "vector": {"fast-all-minilm-l6-v2": [...]}, "payload": {"key": "value"}}
            ]
        },
        {
            "operation_type": "set_payload",
            "payload": {"batch_processed": True},
            "points": ["uuid-1", "uuid-2"]
        },
        {
            "operation_type": "delete_points",
            "ids": ["uuid-old1", "uuid-old2"]
        }
    ]
}
# Returns: success status with count of affected points
```

### Recommendation & Discovery (1 tool)

#### `qdrant-recommend`
Find points similar to positive examples, pushed away from negative examples. Implements look-alike search using Qdrant's Recommendation API.

**Use when:** Finding "similar knowledge", discovering related memories, building recommendation systems, or narrowing search via example-based queries. Supports score threshold filtering and payload filtering.

```python
{
    "collection_name": "my-knowledge",
    "positive": ["uuid-good1", "uuid-good2"],          # points to find similar TO
    "negative": ["uuid-bad1"],                          # points to avoid (optional)
    "limit": 10,                                         # max results to return
    "score_threshold": 0.5,                              # minimum similarity to returned results
    "offset": 0,                                         # pagination offset
    "using": null,                                       # optional — vector name to use for search (auto-detected if null)
    "with_vector": false,                                # include vectors in results
    "with_payload": true,                                # include payload metadata
    "query_filter": {                                    # optional filter to narrow results
        "must": [{"key": "category", "match": {"value": "geography"}}]
    }
}

# Returns: list of dicts with point_id, payload, score (ranked by similarity)
```

**How it works:** The tool embeds the positive example vectors and performs vector similarity search, pushing results away from negative examples. It's essentially a smart similarity search seeded from known-good examples.

**Important constraints:**
- Needs at least 2 points in the collection — with only 1 point, no similar points exist to recommend
- Empty collections return `[]`
- Works best when combined with payload filtering to narrow the result space

## Complete Semantic Memory Workflows

### Workflow 1: Basic Store & Search (Core Memory Flow)
The most common pattern for building a knowledge base or semantic memory.

```python
# 1. Store entries — collections auto-created on first store()
await qdrant_connector.store(Entry(content="The capital of France is Paris", metadata={"category": "geography"}))
await qdrant_connector.store(Entry(content="Japan's capital is Tokyo", metadata={"category": "geography"}))
await qdrant_connector.store(Entry(content="Python uses indentation for blocks", metadata={"category": "programming"}))

# 2. Search by meaning — auto-embedded query, ranked by similarity
results = await qdrant_connector.search("European capitals", limit=5)
# → Returns: Paris entry (high score), Tokyo entry (lower score)

# 3. Filter search — combine semantic + categorical filtering
results = await qdrant_connector.search(
    "programming languages",
    filter_payload={"must": [{"key": "category", "match": {"value": "programming"}}]}
)
```

### Workflow 2: Knowledge Base Maintenance
Managing the lifecycle of stored knowledge over time.

```python
# Audit contents — count and list all entries
count = await qdrant_connector.count_points("my-knowledge")
all_entries = []
offset = None
while True:
    result = await qdrant_connector.list_points("my-knowledge", limit=50, offset=offset)
    all_entries.extend(result["points"])
    offset = result.get("next_offset")
    if not offset:
        break

# Tag entries — update metadata without re-embedding
await qdrant_connector.update_points("my-knowledge", [
    {"id": "uuid-entry-1", "payload": {"reviewed": True, "priority": "high"}},
    {"id": "uuid-entry-2", "payload": {"deprecated": True}}
])

# Remove stale entries — delete specific points
await qdrant_connector.delete_points("my-knowledge", ["uuid-stale-entry"])
```

### Workflow 3: Batch Migration (Model Switching)
Re-embedding all data with a new embedding model in one atomic operation.

```python
# Collect existing entries (without vectors)
old_entries = await qdrant_connector.list_points("my-knowledge", limit=1000, with_vector=True)

# Create new collection for the new model
await qdrant_connector.create_collection("my-knowledge-v2", vector_size=768, distance="Cosine")

# Batch upsert with new embeddings (simulated — in practice use batch_update)
batch_ops = []
for entry in old_entries["points"]:
    new_vector = await embed_with_new_model(entry["payload"]["content"])
    batch_ops.append({
        "operation_type": "upsert",
        "points": [{"id": entry["id"], "vector": {"fast-new-model": new_vector}, "payload": entry["payload"]}]
    })

# Execute in batches of 100
for i in range(0, len(batch_ops), 100):
    await qdrant_connector.batch_update("my-knowledge-v2", batch_ops[i:i+100])
```

### Workflow 4: Recommendation & Discovery
Finding related knowledge based on example memories.

```python
# Find entries similar to a known-good entry (positive-only)
similar = await qdrant_connector.recommend(
    "my-knowledge",
    positive=["uuid-py-entry"],
    limit=5,
    with_payload=True
)

# Find related entries while excluding irrelevant ones (positive + negative)
better_matches = await qdrant_connector.recommend(
    "my-knowledge",
    positive=["uuid-python-entry"],
    negative=["uuid-javascript-entry"],  # exclude JS-related docs
    limit=10,
    score_threshold=0.6
)

# Discover with filtering — find similar Python entries only in programming category
filtered_recommendations = await qdrant_connector.recommend(
    "my-knowledge",
    positive=["uuid-python-entry"],
    query_filter={"must": [{"key": "category", "match": {"value": "programming"}}]}
)
```

### Workflow 5: Collection Lifecycle Management
Setting up, configuring, and maintaining collections.

```python
# Discover existing collections
collections = await qdrant_connector.list_collections()
# → ["default", "my-knowledge"]

# Inspect a collection's health/config
info = await qdrant_connector.get_collection_info("my-knowledge")
print(f"Points: {info['points_count']}")
print(f"Vectors: {info['vector_size']}")
print(f"Status: {info['status']}")  # "green", "yellow", "red"

# Tune indexer — improve indexing speed and quality
await qdrant_connector.update_collection("my-knowledge", optimizer_config={
    "indexing_threshold": 10000,   # lower = faster indexing, higher CPU usage
    "max_segment_size": 500        # smaller segments = faster search but more overhead
})

# Create payload indexes on filterable fields (server mode only)
# Note: Must be done BEFORE HNSW builds for filterable vectors to work
await qdrant_connector.update_collection("my-knowledge", optimizer_config={
    # This triggers payload indexing setup — exact API depends on implementation
})

# Clean up — delete a collection entirely
await qdrant_connector.delete_collection("old-knowledge")
```

## Filter DSL — Complete Reference

Filters work with `qdrant-find`, `qdrant-list-points`, and `qdrant-recommend`. They use Qdrant's filter DSL (`models.Filter`):

### Basic Conditions

```python
# Exact match on payload field
{"must": [{"key": "category", "match": {"value": "geography"}}]}

# Boolean match
{"must": [{"key": "deprecated", "match": {"value": False}}]}

# Numeric range
{"must": [{"key": "score", "range": {"gte": 0.8, "lte": 1.0}}]}

# Text matching (keyword query)
{"must": [{"key": "title", "match": {"text": "quick brown fox"}}]}
```

### Boolean Logic

```python
# MUST + MUST NOT — include A but exclude B
{
    "must": [{"key": "category", "match": {"value": "programming"}}],
    "must_not": [{"key": "deprecated", "match": {"value": True}}]
}

# SHOULD (any match) + MUST (all must match)
{
    "should": [
        {"key": "tag", "match": {"value": "important"}},
        {"key": "tag", "match": {"value": "featured"}}
    ],
    "must": [{"key": "category", "match": {"value": "programming"}}]
}

# Nested filters (filter within filter)
{
    "must": [{
        "key": "metadata",
        "match": {"value": "approved"},
        "filter": {
            "must": [{"key": "priority", "range": {"gte": 5}}]
        }
    }]
}
```

### Important Notes on Filtering

- **Local Qdrant**: Payload filtering may work without indexes for small collections, but results are unreliable. Don't depend on it in production tests.
- **Server Qdrant**: Filtered queries on payload fields require prior indexing via `update_collection()` optimizer config or dedicated index creation. If no index exists, filtered queries return empty or incorrect results.
- **Payload indexes must be created BEFORE HNSW builds** — creating them after breaks filterable vector index and requires full reindexing.

## Production Best Practices for Semantic Memory

### When to use which tool

| Task | Recommended Tool(s) |
|------|-------------------|
| Add a new memory/fact | `qdrant-store` (auto-embeds) |
| Look up by meaning | `qdrant-find` (semantic search) |
| Browse all memories | `qdrant-list-points` + pagination |
| Check memory count | `qdrant-count-points` |
| Find specific entry | `qdrant-get-point` by ID |
| Tag/update metadata | `qdrant-update-points` |
| Remove stale entries | `qdrant-delete-points` |
| Batch-tag or clean up | `qdrant-batch-update` |
| Find similar knowledge | `qdrant-recommend` (look-alike) |
| List known collections | `qdrant-list-collections` |
| Inspect health/config | `qdrant-get-collection-info` |
| Create custom collection | `qdrant-create-collection` |
| Tune indexing settings | `qdrant-update-collection` |
| Remove outdated KB | `qdrant-delete-collection` |

### Semantic memory design tips

1. **Store with good metadata**: Always include structured payload data (categories, sources, timestamps) — they enable filtered search later.
2. **Use collections per domain**: Separate collections for different knowledge domains (e.g., "geography", "programming") to avoid cross-domain contamination in recommendations.
3. **Set score thresholds**: Use `score_threshold` on `qdrant-find` and `qdrant-recommend` to filter out low-quality matches. Start with 0.5-0.7 and tune based on results.
4. **Batch operations for maintenance**: Use `qdrant-batch-update` for bulk tagging, cleanup, or migration — it's far more efficient than individual calls.
5. **Recommend needs examples**: The recommendation tool is most powerful when you have positive examples of good matches. Start with a few known-good entries and discover more.
6. **Monitor collection health**: Regularly check `qdrant-get-collection-info` to monitor point counts, segment status, and optimizer state.

## Key Bug Fixes & Gotchas

### Named Vectors (Critical)
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

### Payload Indexing Must Precede HNSW Build (Server Mode)
Payload indexes must be created BEFORE HNSW builds for filterable vectors to work. Creating them after breaks filterable vector index and requires full reindexing. This is the #1 cause of "filtered search returns empty" in production.

## Testing Patterns

All tests follow TDD workflow:
1. Create `QdrantConnector(url=":memory:", collection_name=f"test_{uuid}")` fixture
2. Store data before querying (collections auto-created on first store)
3. Use UUID-format point IDs
4. For named-vector collections, wrap assertions to handle `{name: [values]}` dict format
5. Skip payload filter tests for local mode with `pytest.skip("...")`
6. Recommend tests need 2+ points in collection
7. Batch operations tested by verifying each operation type independently

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

### "Filtered search returns empty" — The Indexing Issue
If filtered queries return zero results, the most likely cause is missing payload indexes on server-mode Qdrant. Create payload indexes via `update_collection()` optimizer config BEFORE HNSW builds. See [Payload Index docs](https://search.qdrant.tech/md/documentation/manage-data/indexing/).
