# OpenSearch Card Search

This document describes the OpenSearch integration for Magic: The Gathering card search functionality.

## Overview

The OpenSearch integration provides fast, flexible card search capabilities with two primary endpoints:

1. **Autocomplete**: Ultra-fast type-ahead search (optimized for <100ms response times)
2. **Full Search**: Comprehensive search with filtering, sorting, and pagination

### Key Features

- Edge n-gram tokenizer for instant autocomplete
- Multi-field full-text search across card name, oracle text, and type line
- Extensible filter architecture for colors, CMC, types, formats, and more
- Nested card faces support for multi-faced cards
- Automatic indexing via ActiveRecord callbacks
- Admin dashboard for monitoring reindex operations
- Future-ready for semantic search (vector embeddings)

## Architecture

### Service Layer

The OpenSearch integration is organized into service objects:

- **`OpenSearch::BaseService`**: Shared client connection and utilities
- **`OpenSearch::CardIndexer`**: Index management and document creation
- **`OpenSearch::CardSearchService`**: Search query construction and execution

### Background Jobs

- **`OpenSearchReindexJob`**: Batch reindex all cards (500 at a time)
- **`OpenSearchCardUpdateJob`**: Single card indexing/deletion

### State Tracking

- **`OpenSearchSync`** model with AASM state machine tracks reindex operations
- States: `pending` → `indexing` → `completed`/`failed`
- Provides real-time progress for admin dashboard

## Index Schema

### Index Settings

```ruby
{
  number_of_shards: 1,
  number_of_replicas: 0,
  analysis: {
    analyzer: {
      card_name_autocomplete: {
        type: "custom",
        tokenizer: "standard",
        filter: ["lowercase", "card_name_edge_ngram"]
      }
    },
    filter: {
      card_name_edge_ngram: {
        type: "edge_ngram",
        min_gram: 2,
        max_gram: 20
      }
    }
  }
}
```

### Index Mappings

Key fields indexed for search:

- **`name`**: Text with autocomplete analyzer and keyword subfield
- **`oracle_text`**: Full-text searchable
- **`type_line`**: Text with keyword subfield for exact matching
- **`mana_cost`**: Keyword field
- **`cmc`**: Float for mana value filtering
- **`colors`**: Keyword array (W, U, B, R, G)
- **`color_identity`**: Keyword array for commander filtering
- **`keywords`**: Keyword array for mechanics (Flying, Trample, etc.)
- **`card_faces`**: Nested objects with name, mana_cost, type_line, oracle_text, etc.
- **`legalities`**: Object with format → status mappings

## API Endpoints

### 1. Autocomplete Endpoint

Fast type-ahead search for card names.

**Endpoint**: `GET /api/cards/autocomplete`

**Parameters**:
- `q` (required): Query string
- `limit` (optional): Number of results (default: 10, max: 10)

**Example Request**:
```bash
curl "http://localhost:3000/api/cards/autocomplete?q=lightning%20bolt"
```

**Example Response**:
```json
[
  {
    "id": "abc123",
    "name": "Lightning Bolt",
    "type_line": "Instant",
    "mana_cost": "{R}"
  }
]
```

### 2. Search Endpoint

Full search with filters, sorting, and pagination.

**Endpoint**: `GET /api/cards/search`

**Parameters**:
- `q` (optional): Query string (searches name, oracle_text, type_line)
- `page` (optional): Page number (default: 1)
- `per_page` (optional): Results per page (default: 20, max: 100)

**Filter Parameters**:
- `colors[]`: Color identity filter (W, U, B, R, G)
- `color_match`: "exact" for exact color match (default: includes)
- `cmc_min`: Minimum converted mana cost
- `cmc_max`: Maximum converted mana cost
- `types[]`: Type filter (e.g., "creature", "instant")
- `formats[]`: Format legality filter (e.g., "commander", "modern")
- `keywords[]`: Keyword filter (e.g., "flying", "trample")
- `layout`: Layout filter (e.g., "normal", "transform")
- `reserved`: Reserved list filter ("true" or "false")
- `sort`: Sort order ("name", "cmc", "released", default: relevance)

**Example Request**:
```bash
curl "http://localhost:3000/api/cards/search?q=dragon&colors[]=R&cmc_min=4&cmc_max=6&sort=cmc"
```

**Example Response**:
```json
{
  "results": [
    {
      "id": "xyz789",
      "name": "Shivan Dragon",
      "oracle_text": "Flying\n{R}: Shivan Dragon gets +1/+0 until end of turn.",
      "type_line": "Creature — Dragon",
      "mana_cost": "{4}{R}{R}",
      "cmc": 6.0,
      "colors": ["R"],
      "color_identity": ["R"],
      "power": "5",
      "toughness": "5",
      "keywords": ["Flying"],
      "card_faces": [],
      "legalities": {
        "commander": "legal",
        "modern": "legal"
      },
      "score": 12.5
    }
  ],
  "total": 42,
  "page": 1,
  "per_page": 20,
  "total_pages": 3
}
```

## Admin Dashboard Integration

### Endpoints

- `GET /admin/open_search_syncs` - List all sync operations
- `POST /admin/open_search_syncs` - Start new reindex
- `GET /admin/open_search_syncs/:id` - View specific sync details
- `DELETE /admin/open_search_syncs/:id` - Cancel running sync
- `GET /admin/open_search_syncs/progress` - Real-time progress updates

### Starting a Reindex via API

```bash
curl -X POST http://localhost:3000/admin/open_search_syncs \
  -H "Content-Type: application/json"
```

### Monitoring Progress

```bash
curl http://localhost:3000/admin/open_search_syncs/progress
```

**Response**:
```json
{
  "syncs": [
    {
      "id": 1,
      "status": "indexing",
      "total_cards": 50000,
      "indexed_cards": 25000,
      "failed_cards": 0,
      "progress_percentage": 50.0,
      "duration_formatted": "2m 30s"
    }
  ],
  "index_stats": {
    "document_count": 25000,
    "size_in_bytes": 15728640
  }
}
```

## Rake Tasks

### Setup Index

Create the OpenSearch index with mappings:

```bash
rake opensearch:setup
```

### Reindex All Cards

Reindex all cards from the database:

```bash
rake opensearch:reindex
```

This creates an `OpenSearchSync` record and processes cards in batches of 500.

### Reset Index

Delete and recreate the index (WARNING: destroys all indexed data):

```bash
rake opensearch:reset
```

### Check Status

View index statistics and recent syncs:

```bash
rake opensearch:status
```

**Example Output**:
```
OpenSearch Status
==================================================
Index: EXISTS
Document count: 50000
Size: 15.00 MB

Recent Syncs
--------------------------------------------------
✓ #5 - COMPLETED - 2025-10-01 14:30:00
  Progress: 50000/50000 (100.0%)
  Duration: 5m 12s

Database Stats
--------------------------------------------------
Total cards in database: 50000
```

### Test Connection

Verify OpenSearch connectivity:

```bash
rake opensearch:test_connection
```

### Delete Index

Remove the OpenSearch index:

```bash
rake opensearch:delete
```

## Development Setup

### 1. Start OpenSearch

OpenSearch is configured in `docker-compose.yml` and starts automatically with `bin/dev`:

```yaml
opensearch:
  image: opensearchproject/opensearch:2.11.0
  environment:
    - discovery.type=single-node
    - plugins.security.disabled=true
  ports:
    - "9200:9200"
```

Verify OpenSearch is running:
```bash
curl http://localhost:9200
```

### 2. Configure Environment

Set the OpenSearch URL in `.env` (optional, defaults to localhost:9200):

```bash
OPENSEARCH_URL=http://localhost:9200
```

### 3. Create Index

```bash
rake opensearch:setup
```

### 4. Initial Reindex

```bash
rake opensearch:reindex
```

This will index all existing cards in batches of 500.

## Adding New Filters

The filter architecture is designed for easy extension. Here's how to add a new filter:

### 1. Update Index Mappings

Add the field to `app/services/opensearch/card_indexer.rb`:

```ruby
# In index_configuration mappings
properties: {
  # ... existing fields ...
  new_field: {
    type: "keyword"  # or "text", "integer", etc.
  }
}
```

### 2. Include in Document

Add to the `card_document` method:

```ruby
def card_document(card)
  {
    # ... existing fields ...
    new_field: card.new_field
  }
end
```

### 3. Add Filter Logic

Update `build_search_query` in `app/services/opensearch/card_search_service.rb`:

```ruby
# New field filter
if filters[:new_field].present?
  filter_clauses << { term: { new_field: filters[:new_field] } }
end
```

### 4. Update Controller

Add parameter handling in `app/controllers/api/cards_controller.rb`:

```ruby
def build_filters
  filters = {}
  # ... existing filters ...
  filters[:new_field] = params[:new_field] if params[:new_field].present?
  filters
end
```

### 5. Reindex

After adding fields, reindex to populate existing documents:

```bash
rake opensearch:reindex
```

## Automatic Indexing

Cards are automatically indexed/updated when:

- A new card is created
- An existing card is updated
- A card is deleted

This is handled by ActiveRecord callbacks in the `Card` model:

```ruby
after_commit :index_in_opensearch, on: [:create, :update]
after_commit :remove_from_opensearch, on: :destroy
```

These callbacks enqueue `OpenSearchCardUpdateJob` for asynchronous processing.

## Performance Considerations

### Autocomplete Performance

- Uses edge n-gram tokenizer for prefix matching
- Limited to 10 results maximum
- Only returns minimal fields (id, name, type_line, mana_cost)
- Target response time: <100ms

### Search Performance

- Batch indexing processes 500 cards at a time
- Single shard configuration (suitable for <100M documents)
- No replicas in development (set replicas: 1+ in production)
- Indexes are refreshed after bulk operations

### Memory Usage

- Batch size of 500 balances memory usage and throughput
- Each batch holds ~500 Card objects + associations in memory
- Monitor with `OpenSearchSync` progress tracking

## Testing

### Manual Testing

Test autocomplete:
```bash
curl "http://localhost:3000/api/cards/autocomplete?q=bolt"
```

Test search:
```bash
curl "http://localhost:3000/api/cards/search?q=dragon&colors[]=R"
```

Test with filters:
```bash
curl "http://localhost:3000/api/cards/search?cmc_min=4&cmc_max=6&formats[]=commander"
```

### RSpec Tests

Run OpenSearch tests:
```bash
bundle exec rspec spec/services/opensearch/
bundle exec rspec spec/controllers/api/cards_controller_spec.rb
bundle exec rspec spec/jobs/open_search_reindex_job_spec.rb
```

## Troubleshooting

### OpenSearch Not Running

**Error**: Connection refused to localhost:9200

**Solution**: Start OpenSearch via Docker:
```bash
docker-compose up opensearch
```

### Index Doesn't Exist

**Error**: "index_not_found_exception"

**Solution**: Create the index:
```bash
rake opensearch:setup
```

### No Results Returned

**Possible causes**:
1. Index is empty - run `rake opensearch:reindex`
2. Index needs refresh - run `OpenSearch::CardIndexer.new.refresh_index`
3. Query syntax error - check logs for OpenSearch errors

**Check index stats**:
```bash
rake opensearch:status
```

### Slow Autocomplete

**Possible causes**:
1. Too many results - reduce limit parameter
2. Complex query - simplify query string
3. Index not optimized - check index settings

**Verify autocomplete settings**:
```bash
curl http://localhost:9200/cards/_mapping
```

### Reindex Failures

**Check sync status**:
```bash
rake opensearch:status
```

**Retry failed sync**:
1. Via admin API or dashboard
2. Or create new sync: `rake opensearch:reindex`

**Common issues**:
- OpenSearch connection timeout - increase timeout in initializer
- Memory issues - reduce BATCH_SIZE in `OpenSearchReindexJob`
- Invalid data - check error logs for specific cards

## Future Enhancements

### Semantic Search

The index includes commented-out support for vector embeddings:

```ruby
# embedding: {
#   type: "dense_vector",
#   dims: 768
# }
```

To enable semantic search:

1. Uncomment the `embedding` field in index mappings
2. Generate embeddings for cards (using a model like BERT)
3. Add `knn` query support in `CardSearchService`
4. Reindex with embedding data

### Aggregations

Add faceted search with aggregations:

```ruby
# In search query
aggs: {
  types: {
    terms: { field: "type_line.keyword" }
  },
  colors: {
    terms: { field: "color_identity" }
  }
}
```

### Suggestions

Implement "Did you mean?" functionality using OpenSearch suggestion API.

### Highlighting

Add search term highlighting in results:

```ruby
highlight: {
  fields: {
    name: {},
    oracle_text: {}
  }
}
```

## Production Deployment

### Configuration

1. Set `OPENSEARCH_URL` environment variable to production cluster
2. Update index settings:
   - Set `number_of_replicas: 1` (or more for HA)
   - Consider increasing `number_of_shards` for large datasets (>10M documents)

### Initial Setup

```bash
RAILS_ENV=production rake opensearch:setup
RAILS_ENV=production rake opensearch:reindex
```

### Monitoring

- Monitor index stats via admin dashboard
- Set up alerts for failed syncs
- Monitor OpenSearch cluster health
- Track query performance metrics

### Backups

OpenSearch data can be regenerated from PostgreSQL, but consider:
- Taking snapshots of OpenSearch indices for faster recovery
- Backing up `open_search_syncs` table for historical tracking
