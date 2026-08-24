# Operations

## Runtime roles

Build `Dockerfile` once and run the same immutable image with these commands:

- `bin/rails server` for web;
- `bin/jobs start` for workers;
- `bin/release` once before updated web and worker processes start.

`bin/docker-entrypoint` validates production configuration before any role runs.
The web readiness endpoint is `/ready`; `bin/worker-health` checks worker
heartbeats in the same logical PostgreSQL database.

## Storage and mail

Set `STORAGE_SERVICE=local` with a durable `ACTIVE_STORAGE_ROOT`, or select the
S3-compatible service and configure the names documented in `.env.example`. Set
`MAIL_DELIVERY_METHOD=none` when the application has no delivery transport, or
configure the portable SMTP settings.

## Backups and restore

`bin/backup` writes a PostgreSQL custom-format dump, metadata, and checksum.
`bin/backup-prune` applies retention. `bin/restore` requires an explicitly
disposable target unless `ALLOW_DESTRUCTIVE_RESTORE=1` is set. Validate the full
path with `bin/restore-drill`; never infer restore safety from backup creation
alone.

## Local topology

`compose.yaml` defines PostgreSQL, release, web, and worker services. Optional
development mail and S3-compatible object storage use explicit Compose profiles.
Copy `compose.env.example`, supply secrets outside Git, and validate with
`docker compose config` before starting the topology.
