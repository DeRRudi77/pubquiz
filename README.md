# Pubquiz

A real-time, collaborative pub quiz built with Ruby on Rails and Hotwire. A host
creates a game with rounds and questions, players join from their phones via a
public link, the host scores answers live, and the leaderboard updates on every
screen in real time over ActionCable.

## How it works

There are two kinds of participants:

- **Host** — a registered (Devise) user who owns the game. The host creates the
  game, configures rounds and questions, starts it, advances rounds, scores
  answers, and reveals results.
- **Players** — anonymous, no account required. They open the public join link,
  pick or name a team, and submit one answer per question. Player identity is
  kept in a Redis-backed session (24h TTL), not a database record.

End to end: the host builds a game → shares the join link → players join teams →
the host starts the game → each round players answer while the host scores → the
host advances through every round → the host processes and then reveals the final
results, ranked by total points. Every state change is broadcast live to all
connected browsers via Turbo Streams.

## Domain model

```
Game ─┬─ Round ── Question ── TeamAnswer
      └─ Team ─────────────────┘
```

- **Game** — the quiz. Owns a number of rounds and teams; tracks the current round.
- **Round** — a group of questions (10 by default). Belongs to a game.
- **Question** — a question/answer pair within a round.
- **Team** — a competing team in a game; accumulates `total_points`.
- **TeamAnswer** — one team's answer to one question, plus the points awarded.
- **Player** — a plain Ruby object (not ActiveRecord) representing an anonymous
  player session, stored in Redis with a 24-hour expiry.

All database tables use **UUID** primary keys (`pgcrypto` / `gen_random_uuid()`) —
don't assume integer IDs.

## Game lifecycle

State is tracked with enums and advanced through `ActiveInteraction` service
objects in `app/interactions/games/`, triggered by custom member routes on `games`.

```
Game:  pending_start ──▶ started ──▶ pending_results ──▶ finished
```

| Action (route)                     | Interaction             | Effect                                                         |
| ---------------------------------- | ----------------------- | -------------------------------------------------------------- |
| `PATCH /games/:id/start`           | `Games::StartGame`      | Game → `started`, first round → `started`, pre-creates answers |
| `PATCH /games/:id/next_round`      | `Games::AdvanceRound`   | Current round → `finished`, next round → `started`             |
| `PATCH /games/:id/process_results` | `Games::ProcessResults` | Final round → `finished`, game → `pending_results`             |
| `PATCH /games/:id/show_results`    | `Games::ShowResults`    | Game → `finished`, recompute totals, reveal leaderboard        |
| `PATCH /team_answers/:id`          | `Games::ScoreAnswer`    | Set answer points; when a round is fully scored, mark `scored` |

Other enums:

- **Round:** `pending_start`, `started`, `finished`, `scored`
- **TeamAnswer:** `pending`, `correct`, `incorrect`

A team's `total_points` is the sum of its scored answers; results are grouped by
points (ties share a rank) and shown descending.

## Tech stack

- **Ruby** 3.4.9 (`.ruby-version`), **Rails** 8.1.3
- **PostgreSQL** — UUID primary keys throughout (pgcrypto)
- **Redis** — caching, ActionCable adapter, anonymous player sessions
- **Puma** — web server
- **Hotwire** — Turbo + Stimulus for real-time UI; ActionCable transport
- **esbuild** (via `jsbundling-rails`) — JS bundling; **sassc-rails** for CSS
- **Slim** — view templates (`app/views/**/*.slim`)
- **Devise** — host authentication
- **active_interaction** — service objects for game-flow logic
- **StandardRB** — linting/formatting; **lefthook** — git hooks

## Getting started — Docker

The whole stack — Rails (`web`), Postgres (`database`), and Redis (`redis`) — runs
via Docker Compose:

```bash
docker compose up
```

The app is served at <http://localhost:3000>. Source is bind-mounted, so view and
JS changes reload live (esbuild runs in `--watch`). On first boot the `web`
container installs gems and JS deps and runs `db:prepare` automatically.

Credentials decrypt via the gitignored `config/master.key` (bind-mounted into the
container); alternatively set `RAILS_MASTER_KEY` in the environment (e.g. CI) to
override the file:

```bash
RAILS_MASTER_KEY=$(cat config/master.key) docker compose up
```

## Getting started — local (no Docker)

Prerequisites:

- Ruby 3.4.9 and Node.js 20+
- A running **PostgreSQL** with a role `pubquiz` / password `pubquiz`
- A running **Redis** on `localhost:6379`

Then:

```bash
bin/setup   # install gems + JS deps, install git hooks, prepare the database
bin/dev     # start the web server and esbuild watcher (Procfile.dev)
```

- `bin/setup` runs `bundle install`, `bundle exec lefthook install`, `bin/yarn`,
  and `bin/rails db:prepare`.
- `bin/dev` uses foreman to run two processes from `Procfile.dev`:
  `web` (Rails on port 3000) and `js` (`npm run build -- --watch`).

The app is served at <http://localhost:3000>.

## Configuration

Configuration is via environment variables (all have sensible local defaults):

| Variable            | Default                       | Purpose                                |
| ------------------- | ----------------------------- | -------------------------------------- |
| `PGHOST`            | `localhost`                   | Postgres host                          |
| `PGUSER`            | `pubquiz`                     | Postgres user                          |
| `PGPASSWORD`        | `pubquiz`                     | Postgres password                      |
| `REDIS_URL`         | `redis://localhost:6379/1`    | Redis connection (cache + ActionCable) |
| `RAILS_MAX_THREADS` | `5`                           | Database connection pool size          |
| `PORT`              | `3000`                        | Web server port (`bin/dev`)            |
| `RAILS_MASTER_KEY`  | — (reads `config/master.key`) | Decrypts `config/credentials.yml.enc`  |

`config/master.key` is gitignored — credentials won't decrypt without it.
Databases: `pubquiz_development`, `pubquiz_test`, `pubquiz_production`.

## Development workflow

- `bin/dev` — run web + JS watch together (the normal way to develop).
- `npm run build` — one-off JS build (esbuild bundles `app/javascript/application.js`
  into `app/assets/builds/`); `bin/dev` runs it with `--watch`.
- Views are **Slim** in `app/views/`. Stimulus controllers live in
  `app/javascript/controllers/`, ActionCable channels in `app/javascript/channels/`.
- Game-flow logic lives in `app/interactions/games/`, not in controllers.

## Testing

Minitest with fixtures; tests run in parallel (one worker per CPU) and use Devise
integration helpers.

```bash
bin/rails test                 # run the full suite
bin/rails test test/models     # scope to a path
```

Test layout: `test/models`, `test/controllers`, `test/interactions`,
`test/system`, `test/channels`. System tests (`bin/rails test:system`, Capybara +
Selenium Chrome) are currently non-functional scaffold and fail out of the box —
use `bin/rails test` as the suite of record.

## Linting & git hooks

StandardRB enforces style. lefthook installs a **pre-commit** hook that runs
`standardrb` on staged `*.rb` files, auto-fixes, and re-stages them.

```bash
bundle exec standardrb         # lint
bundle exec standardrb --fix   # autofix
bundle exec lefthook install   # install hooks (bin/setup already does this)
```

Bypass the hook in a pinch with `git commit --no-verify`.

## Routes reference

| Method             | Path                              | Action                      | Auth                                 |
| ------------------ | --------------------------------- | --------------------------- | ------------------------------------ |
| `GET`              | `/`                               | `games#index`               | required                             |
| `GET/POST`         | `/games`, `/games/new`            | `games#index/new/create`    | required                             |
| `GET/PATCH/DELETE` | `/games/:id`                      | `games#show/update/destroy` | required                             |
| `PATCH`            | `/games/:id/start`                | `games#start`               | required                             |
| `PATCH`            | `/games/:id/next_round`           | `games#next_round`          | required                             |
| `PATCH`            | `/games/:id/process_results`      | `games#process_results`     | required                             |
| `PATCH`            | `/games/:id/show_results`         | `games#show_results`        | required                             |
| **`GET`**          | **`/games/:id/join`**             | **`games#join`**            | **public**                           |
| `GET/PATCH`        | `/rounds/:id/edit`, `/rounds/:id` | `rounds#edit/update`        | required                             |
| `POST`             | `/rounds/:round_id/questions`     | `rounds/questions#create`   | required                             |
| `DELETE`           | `/questions/:id`                  | `rounds/questions#destroy`  | required                             |
| `GET/PATCH`        | `/teams/:id`                      | `teams#show/update`         | host required; players session-based |
| `PATCH`            | `/team_answers/:id`               | `team_answers#update`       | required                             |

Everything except `games#join` requires `authenticate_user!`; game-management
actions additionally check ownership via `require_game_owner!` (returns **404**,
not 403, so non-owners can't tell a game exists).

## Conventions

- **Commits:** [Conventional Commits](https://www.conventionalcommits.org) —
  `type(scope): subject` (e.g. `feat(games): add live scoring`).
- **Reviews:** [Conventional Comments](https://conventionalcomments.org) —
  `<label> [decorations]: <subject>`.
- Do not add AI attribution to commits or PR descriptions.

See `CLAUDE.md` for the full contributor conventions.

## Project layout

```
app/
  controllers/        # thin controllers; respond with Turbo Streams
  interactions/games/ # game-flow service objects (StartGame, AdvanceRound, …)
  models/             # Game, Round, Question, Team, TeamAnswer, Player, User
  models/concerns/    # RelationshipUpdatable (keeps child record counts in sync)
  views/              # Slim templates
  javascript/
    controllers/      # Stimulus controllers
    channels/         # ActionCable channels
config/               # routes, database.yml, cable.yml, environments
test/                 # models, controllers, interactions, system, channels
```
