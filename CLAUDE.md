# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Overview

Pubquiz is a Rails app to host and manage a pub quiz. A user creates a **Game**, which
contains **Rounds**, which contain **Questions**. **Teams** join a game and submit a
**TeamAnswer** per question; the host scores answers and results are shown live.

Hierarchy: `Game → Round → Question` and `Game → Team → TeamAnswer`.

## Stack

- **Ruby** 3.4.9 (`.ruby-version`), **Rails** 7.1.6
- **PostgreSQL** — UUID primary keys throughout (pgcrypto)
- **Redis** — caching / sessions / ActionCable
- **Puma** web server
- **Hotwire**: Turbo + Stimulus, **ActionCable** for real-time updates
- **esbuild** bundles JS (no Webpacker); **sassc-rails** for CSS
- **Slim** view templates
- **Devise** authentication
- **StandardRB** for linting/formatting

## Commands

```bash
bin/setup            # install deps + prepare DB
bin/dev              # run web + JS watch (Procfile.dev)
bin/rails test       # run Minitest suite (append a path to scope)
bin/rails test:system # system tests (Capybara + Selenium)
bundle exec standardrb # lint
bundle exec standardrb --fix # autofix
npm run build        # one-off JS build (bin/dev runs --watch)
docker-compose up    # Postgres + Redis if not running locally
bundle exec lefthook install # install git hooks (run once; bin/setup does it)
```

## Git hooks

- **lefthook** runs a **pre-commit** hook that lints staged `*.rb` files with StandardRB
  (`bundle exec standardrb`). Config in `lefthook.yml`. Offenses block the commit.
- Installed automatically by `bin/setup`; existing clones run `bundle exec lefthook install` once.
- Bypass in a pinch with `git commit --no-verify`.

## Architecture & conventions

- **State via enums:**
  - `Game`: `pending_start`, `started`, `pending_results`, `finished`
  - `Round`: `pending_start`, `started`, `finished`, `scored`
  - `TeamAnswer`: `pending`, `correct`, `incorrect`
- **Game flow actions:** `start!`, `next_round!`, `process_results!`, `show_results!`
  (custom member routes on `games`).
- **Real-time:** `Game`, `Round`, `Team` include `Turbo::Broadcastable` and broadcast over
  ActionCable; controllers respond with Turbo Streams (partial replacement, not full reloads).
- **`RelationshipUpdatable` concern** (`app/models/concerns/`) — auto creates/destroys child
  records to match a count (e.g. N questions per round, N teams per game).
- **Auth:** Devise. `authenticate_user!` is required everywhere except `games#join` (GET).
- **Views are Slim** (`app/views/**/*.slim`). Stimulus controllers live in
  `app/javascript/controllers/`, ActionCable channels in `app/javascript/channels/`.

## Commits & reviews

- **Commits:** always use [Conventional Commits](https://www.conventionalcommits.org) —
  `type(scope): subject` (e.g. `feat(games): add live scoring`, `fix(rounds): correct enum guard`).
  Types: `feat`, `fix`, `build`, `chore`, `ci`, `docs`, `refactor`, `perf`, `test`, `style`.
  Breaking changes use `!` (e.g. `build(deps)!: upgrade to Rails 7.1`).
- **Reviews:** always use [Conventional Comments](https://conventionalcomments.org) —
  `<label> [decorations]: <subject>`. Labels: `praise`, `nitpick`, `suggestion`, `issue`,
  `question`, `thought`, `chore`. Mark non-blocking notes `(non-blocking)`.
- **No AI attribution:** never add `Co-Authored-By: Claude` (or any Claude/AI attribution)
  to commit messages, and never add "Generated with Claude Code" to PR descriptions.

## Testing

- **Minitest** with fixtures; tests run in parallel.
- Layout: `test/models/`, `test/controllers/`, `test/system/`, `test/channels/`.
- System tests use Capybara + Selenium.

## Gotchas

- Needs a local **Postgres** role `pubquiz` / `pubquiz` and **Redis** running — or use
  `docker-compose up`.
- All tables use **UUID** primary keys; don't assume integer IDs.
- `config/master.key` is gitignored — credentials won't decrypt without it.
