# Mesophotic.org

A Ruby on Rails application that serves as a curated database of scientific publications on mesophotic coral ecosystems.

## Stack

- **Ruby** 3.2 / **Rails** 6.1
- **Database**: SQLite3 (all environments)
- **Frontend**: Sprockets, Bootstrap 3 (bootstrap-sass), jQuery, Turbolinks, CoffeeScript, SCSS
- **Auth**: Devise
- **Admin**: RailsAdmin (mounted at `/admin/db`)
- **Dev environment**: Nix flake (enter with `nix develop` or direnv)

## Development

### Setup

```sh
nix develop        # or let direnv handle it
bundle install
rails db:setup
rails s            # starts Puma on port 8765
```

### Environment variables

Managed via Figaro (`config/application.yml`, gitignored). AWS credentials are needed for S3/DynamoDB in production.

### Tests

Minitest with fixtures. Test generators are disabled (`config.generators.test_framework false`).

```sh
rails test
```

### Dependencies

After changing the Gemfile, update the Nix gemset:

```sh
bundle lock
bundix
```

## Architecture

### Key models

- `Publication` — the central model. Heavy use of scopes for search/filtering, HABTM associations to `Location`, `Field`, `Platform`, `Focusgroup`, `Site`, `Species`. Has `friendly_id` slugs and `paper_trail` versioning. PDF attachments via Active Storage.
- `User` — Devise-based authentication with confirmation.

### Conventions

- ERB templates (not Slim/Haml)
- Model annotations via the `annotate` gem (schema comments at top of model files)
- Constants defined on models for enumerations (e.g. `PUBLICATION_TYPES`, `PUBLICATION_FORMATS`)
- HABTM join tables for many-to-many relationships
- `before_save` callbacks for creating associated records from form inputs
- View helpers for formatting and filtering logic
- `render_async` for deferred partial loading
- Background jobs via Active Job (default async adapter)
- Cron via `whenever` gem (`config/schedule.rb`)

### Engines

- `engines/dual_range_slider/` — custom Rails engine for the dual range slider UI component

### Frontend

- Bootstrap 3 grid layout with custom SCSS
- Bootstrap Icons (recently replaced glyphicons and Font Awesome)
- jQuery UJS for AJAX
- Turbolinks for page transitions
- Asset pipeline via Sprockets; no Webpacker/esbuild/importmap

## Code style

- No linter currently configured. Follow existing patterns in the codebase.
- Prefer simple, readable code consistent with Rails conventions.
- Keep views in ERB. Use partials in `app/views/shared/` for reusable components.
- SQL-heavy scopes in models are fine — this app leans into ActiveRecord.

## Deployment

- Puma (1 worker, 1–3 threads)
- Production assets served from `assets.mesophotic.org`
- AWS S3 for Active Storage, DynamoDB for session store
- New Relic for monitoring (production only)
