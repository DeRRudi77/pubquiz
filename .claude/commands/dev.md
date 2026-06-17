---
description: Start the dev server (web + JS watch)
---

Start the app with `bin/dev`, which runs the Puma web server and the esbuild `--watch`
JS build together via `Procfile.dev`. Ensure Postgres and Redis are running first.

Alternatively, `docker compose up` runs the full stack — Rails (web), Postgres, and Redis —
in containers; the `web` container runs `bin/dev` itself, so no separate host process or
local Ruby/Node is needed.
