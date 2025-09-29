# Scryfall Sync System Documentation

## Overview

The Scryfall Sync system is a comprehensive solution for importing and maintaining Magic: The Gathering card data from Scryfall's bulk data API. It handles downloading, processing, and importing millions of card records efficiently using background jobs and batch processing.

## Architecture

### Core Components

1. **Rake Tasks** (`lib/tasks/scryfall.rake`)
   - Entry point for all sync operations
   - Provides CLI interface for manual syncing
   - Status monitoring and reporting

2. **Background Jobs**
   - `ScryfallSyncJob`: Handles downloading bulk data files
   - `ScryfallProcessingJob`: Processes downloaded files and orchestrates batch imports
   - `ScryfallBatchImportJob`: Imports card data in configurable batches

3. **Models**
   - `ScryfallSync`: Tracks sync operations with state machine and progress monitoring
   - Card data models: `Card`, `CardSet`, `CardPrinting`, `CardFace`, `CardRuling`, `CardLegality`, `RelatedCard`

4. **Services**
   - `Scryfall::CardMapper`: Maps Scryfall JSON data to database models
   - `Scryfall::RulingMapper`: Handles card ruling imports
   - `Scryfall::BulkData`: ActiveResource client for Scryfall API

## Data Types

The system supports five types of bulk data imports:

### 1. Oracle Cards
- Core card data without printings
- Contains oracle text, rules, and gameplay attributes
- Smallest dataset, ideal for gameplay applications

### 2. Unique Artwork
- Cards with unique artwork across all printings
- Includes both oracle and printing information
- Good balance between data completeness and size

### 3. Default Cards
- One printing per oracle card (latest or most recent)
- Includes printing-specific data like prices and images

### 4. All Cards
- Complete dataset with every printing
- Largest dataset with full historical data
- Includes promo versions, special editions, etc.

### 5. Rulings
- Official rulings for all cards
- Linked to cards via oracle_id
- Updated frequently with new rulings

## Usage

### Command Line Interface

#### Sync Specific Data Type
```bash
# Sync a specific bulk data type
rake scryfall:sync[oracle_cards]
rake scryfall:sync[unique_artwork]
rake scryfall:sync[default_cards]
rake scryfall:sync[all_cards]
rake scryfall:sync[rulings]

# Or use dedicated tasks
rake scryfall:sync:oracle_cards
rake scryfall:sync:unique_artwork
rake scryfall:sync:default_cards
rake scryfall:sync:all_cards
rake scryfall:sync:rulings
```

#### Sync All Data Types
```bash
rake scryfall:sync:all
```

#### Process Downloaded Data
```bash
# Process already downloaded data without re-downloading
rake scryfall:process[oracle_cards]
```

#### Check Status
```bash
rake scryfall:status
```

### Status Output

The status command provides comprehensive information:
- Download status for each data type
- Processing progress with percentage and record counts
- Active background job counts
- Database statistics (total cards, sets, printings, etc.)

Example output:
```
Scryfall Sync Status:
----------------------------------------------------------------------------------------------------
Type                 Status          Download                  Processing
----------------------------------------------------------------------------------------------------
oracle_cards         ✅ Complete     v2024.01.15 (01/15 10:30) ✅ 28453 records
unique_artwork       🔄 Downloading  v2024.01.15 (01/15 10:31) ⏳ Queued
default_cards        ✅ Complete     v2024.01.14 (01/14 22:00) 🔄 45% (45000/100000)
all_cards           ❌ Never synced  -                         -
rulings             ✅ Complete      v2024.01.15 (01/15 09:00) ✅ 15234 records
----------------------------------------------------------------------------------------------------

Active Jobs:
  Processing: 1
  Batch Import: 25

Database Statistics:
  Cards: 28453
  Card Sets: 542
  Card Printings: 87234
  Card Rulings: 15234
  Card Legalities: 341436
```

## Processing Flow

### 1. Download Phase
1. Check if sync is already in progress
2. Fetch bulk data info from Scryfall API
3. Compare versions to determine if update needed
4. Download file to `storage/scryfall/{sync_type}/`
5. Clean up old downloaded files
6. Automatically queue processing job

### 2. Processing Phase
1. Count total records in downloaded file
2. Read file line by line (streaming for memory efficiency)
3. Parse JSON objects and batch them
4. Queue batch import jobs for parallel processing
5. Track progress and update status

### 3. Import Phase
1. Process batches in parallel via background jobs
2. Map Scryfall data to database models
3. Handle relationships (sets, faces, legalities, etc.)
4. Update or create records as needed

## State Management

### Download States (AASM)
- `pending`: Initial state, waiting to start
- `downloading`: Actively downloading file
- `completed`: Successfully downloaded
- `failed`: Download failed with error
- `cancelled`: Manually cancelled

### Processing States
- `nil`: Not started
- `queued`: Waiting to start processing
- `processing`: Actively processing records
- `completed`: All records processed
- `failed`: Processing failed with error

## Progress Tracking

The system tracks detailed progress information:
- **total_records**: Total number of records in file
- **processed_records**: Number of records queued for import
- **failed_batches**: Count of failed batch imports
- **last_processed_batch**: Latest batch number processed
- **processing_started_at**: When processing began
- **processing_completed_at**: When processing finished

Progress percentage and estimated completion time are calculated dynamically.

## Configuration

### Batch Size
Default: 500 records per batch
Configurable via `batch_size` column in `scryfall_syncs` table

### Storage Location
Files are stored in: `storage/scryfall/{sync_type}/`
Old files are automatically cleaned up after successful sync

### Queue Configuration
- `ScryfallSyncJob`: Uses `:default` queue
- `ScryfallProcessingJob`: Uses `:default` queue
- `ScryfallBatchImportJob`: Uses `:low` queue for bulk operations

## Error Handling

### Retry Logic
- Failed batches are tracked but don't stop overall processing
- Individual record failures are logged but don't fail the batch
- Network errors during download trigger job retry

### Logging
- Detailed logging at each phase
- Error messages stored in `error_message` field
- Failed record details logged with IDs for debugging

### Cancellation
- Downloads can be cancelled mid-stream
- Cancelled downloads clean up partial files
- Associated background jobs are destroyed on cancellation

## Database Schema

### Core Tables
- **cards**: Oracle card data (canonical version)
- **card_sets**: Magic sets and expansions
- **card_printings**: Individual printings of cards
- **card_faces**: Multi-faced card data (transform, modal, etc.)
- **card_rulings**: Official rulings
- **card_legalities**: Format legalities
- **related_cards**: Relationships between cards (tokens, meld, etc.)
- **scryfall_syncs**: Sync operation tracking

## Performance Considerations

### Memory Management
- Streaming file processing (no full file load)
- Batch processing to limit memory per job
- Automatic cleanup of old files

### Parallel Processing
- Multiple batch import jobs run in parallel
- Configurable batch size for optimization
- Low priority queue for batch imports

### Database Optimization
- Bulk inserts where possible
- Upsert operations for updates
- Indexed foreign keys and lookup fields

## Monitoring

### Active Job Monitoring
Check background job status:
```ruby
# In Rails console
ScryfallSync.find(sync_id).active_jobs
ScryfallSync.find(sync_id).processing_jobs
```

### Database Growth
Monitor with `rake scryfall:status` or:
```ruby
Card.count
CardPrinting.count
CardRuling.count
```

## Troubleshooting

### Common Issues

1. **Sync Already in Progress**
   - Check status with `rake scryfall:status`
   - Cancel if needed via Rails console

2. **Download Failures**
   - Check network connectivity
   - Verify Scryfall API is accessible
   - Review error_message in sync record

3. **Processing Stuck**
   - Check background job queue health
   - Look for failed batch jobs
   - Review logs for specific errors

4. **High Memory Usage**
   - Reduce batch_size in sync record
   - Ensure old files are cleaned up
   - Check for job queue backlog

### Manual Intervention

```ruby
# Rails console commands

# Find stuck sync
sync = ScryfallSync.latest_for_type("oracle_cards")

# Cancel a sync
sync.cancel! if sync.cancelable?

# Retry processing
ScryfallProcessingJob.perform_later(sync.id)

# Check job status
sync.processing_jobs.count
sync.active_jobs.pluck(:class_name)
```

## Best Practices

1. **Initial Setup**
   - Start with `oracle_cards` for core data
   - Add `rulings` for gameplay information
   - Use `default_cards` or `unique_artwork` for images
   - Only use `all_cards` if you need complete history

2. **Regular Updates**
   - Schedule daily sync for frequently changing data
   - Run `rake scryfall:status` to monitor health
   - Keep only latest version of bulk files

3. **Performance Tuning**
   - Adjust batch_size based on server capacity
   - Run imports during low-traffic periods
   - Monitor database growth and optimize indexes

## Integration Points

### With Rails Application
- Models provide ActiveRecord interface
- Background jobs integrate with existing job infrastructure
- Storage uses Rails storage paths

### With External Services
- Scryfall API for bulk data endpoints
- Can be extended to sync prices, market data
- Webhook support could be added for real-time updates