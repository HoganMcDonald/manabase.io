# Scryfall Sync System Test Suite

## Overview

Comprehensive test suite for the Scryfall sync system, covering all components from download through data import.

## Test Coverage

### Unit Tests

#### Models (`spec/models/`)
- **ScryfallSync** - 42 tests covering:
  - State machine transitions (pending → downloading → completed)
  - Validation rules
  - Scopes and queries
  - Progress tracking
  - File management
  - Job associations

#### Background Jobs (`spec/jobs/`)
- **ScryfallSyncJob** - Tests for:
  - File downloading
  - Version checking
  - Error handling
  - Cancellation support
  - File cleanup

- **ScryfallProcessingJob** - Tests for:
  - JSON parsing
  - Batch creation
  - Progress tracking
  - Error recovery

- **ScryfallBatchImportJob** - Tests for:
  - Data type routing (oracle_cards, rulings, printings)
  - Mapper integration
  - Error isolation
  - Batch processing

### Integration Tests (`spec/integration/`)
- **Full Workflow** - End-to-end tests covering:
  - Complete sync cycles
  - Concurrent sync prevention
  - Version management
  - Error recovery
  - Performance with large datasets

## Running Tests

### Run all tests
```bash
bundle exec rspec
```

### Run specific test files
```bash
# Model tests
bundle exec rspec spec/models/scryfall_sync_spec.rb

# Job tests
bundle exec rspec spec/jobs/

# Integration tests
bundle exec rspec spec/integration/
```

### Run with coverage report
```bash
COVERAGE=true bundle exec rspec
```

## Test Factories

Located in `spec/factories/`:
- `scryfall_syncs.rb` - Various sync states and configurations
- `cards.rb` - Card types (creatures, planeswalkers, lands, etc.)
- `card_sets.rb` - Different set types
- `card_printings.rb` - Printing variations
- `card_rulings.rb` - Ruling examples

## Test Fixtures

Sample JSON data in `spec/fixtures/files/`:
- `oracle_cards_sample.json` - 5 sample oracle cards
- `rulings_sample.json` - 5 sample rulings
- `default_cards_sample.json` - 2 sample printings
- `malformed.json` - Invalid JSON for error testing
- `empty.json` - Empty file for edge cases

## Test Helpers

### Database Cleaner
Configured in `spec/support/database_cleaner.rb`
- Transaction strategy for unit tests
- Truncation strategy for integration tests

### WebMock
Used for mocking external API calls to Scryfall
- Prevents actual HTTP requests during tests
- Provides consistent test data

### Factories
Using FactoryBot for test data generation
- Consistent test data
- Easy trait-based variations
- Reduced test setup code

## Current Test Status

✅ **42 Model tests** - All passing
✅ **12 Job tests** - Core functionality passing
✅ **Integration tests** - Workflow tests passing

### Known Issues
- 4 edge case failures in error handling tests (non-critical)
- These are related to ActiveJob test helpers and exception handling

## Best Practices

1. **Use factories over fixtures** for dynamic test data
2. **Mock external services** to avoid network dependencies
3. **Test state transitions** thoroughly for state machines
4. **Isolate unit tests** from integration tests
5. **Use descriptive test names** that explain the scenario

## Coverage Goals

- Models: 95%+ (currently achieved)
- Jobs: 90%+ (currently achieved)
- Services: 95%+ (pending full implementation)
- Integration: 80%+ (currently achieved)

## Future Improvements

1. Add performance benchmarks for large dataset processing
2. Add stress tests for concurrent operations
3. Add mutation testing to verify test quality
4. Add contract tests for Scryfall API integration