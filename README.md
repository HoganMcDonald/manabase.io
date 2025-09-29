# Manabase.io

A modern Magic: The Gathering deck building and collection management platform.

## Features

- **Scryfall Data Sync**: Complete card database with automatic updates from Scryfall
- **Deck Building**: Create and manage Magic decks with real-time card search
- **Collection Tracking**: Track your card collection and see what you need
- **Modern Stack**: Rails 8, React, TypeScript, Inertia.js

## Documentation

- [Scryfall Sync System](docs/scryfall-sync.md) - Card data import and synchronization

## Quick Start

```bash
# Setup the application
bin/setup

# Start the development server
bin/dev

# Sync card data from Scryfall
rake scryfall:sync:oracle_cards
rake scryfall:sync:rulings
```

The application will be available at http://localhost:3000

## Development

### Requirements

- Ruby 3.4+
- PostgreSQL
- Redis (for background jobs)
- Node.js 18+

### Background Jobs

The application uses Solid Queue for background job processing. Jobs are automatically started with `bin/dev`.

### Testing

```bash
# Run all tests
bin/rails test

# Run specific test file
bin/rails test test/models/card_test.rb
```

## Deployment

The application is configured for deployment with Kamal. See `config/deploy.yml` for configuration.

```bash
# Deploy to production
kamal deploy
```

## License

MIT