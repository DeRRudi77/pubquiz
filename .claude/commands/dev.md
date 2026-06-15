---
description: Start the dev server (web + JS watch)
---

Start the app with `bin/dev`, which runs the Puma web server and the esbuild `--watch`
JS build together via `Procfile.dev`. Ensure Postgres and Redis are running first
(or `docker-compose up`).
