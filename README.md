# Pubquiz

A Ruby On Rails application to host and manage a pubquiz. Create a game, rounds questions and answers. Define a number of teams and start a game. 

# Requirements
* Ruby: 3.x
* Database: Postgres
* Redis

# Run with Docker

The whole stack — Rails (web), Postgres, and Redis — runs via Docker Compose:

```bash
docker compose up
```

The app is served at http://localhost:3000. Source is bind-mounted, so view and
JS changes reload live (esbuild runs in `--watch`). Credentials decrypt via the
gitignored `config/master.key` (bind-mounted into the container); alternatively set
`RAILS_MASTER_KEY` in the environment (e.g. CI) to override the file.

Without Docker, install Ruby/Node locally and run `bin/setup` then `bin/dev`.
