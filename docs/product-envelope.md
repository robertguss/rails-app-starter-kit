# Product and Deployment Envelope

Status: accepted direction

Last updated: 2026-08-24

## Applications this starter should serve

### Small internal tools

- One app per team, department, or bounded workflow
- Explicitly approved staff audience
- Google Workspace authentication commonly available
- Reads from third-party systems such as Canvas, Populi, Airtable, Watermark,
  and Circle
- User-triggered commands in external systems
- CSV/XLSX imports and report exports
- Durable background work with progress and partial-failure reporting
- Deployment to Render for work, with Fly.io or an owned VM remaining possible

The team boundary usually replaces a need for generic tenant or role systems.
An app may add a simple local operator permission when some approved users
should not execute sensitive provider writes.

### Personal and family applications

- One family or a small known audience
- Password or Google login
- Parent account with child profiles where relevant
- Rich React interactions and media
- Easy deployment to an exe.dev VM
- Low idle-resource cost without requiring a rewrite when the app grows

Event Horizon is the primary validation case.

### Product experiments

- Fast initial setup
- A database and jobs available without introducing separate infrastructure
  products
- Clear seams for optional email, object storage, billing, AI, and search
- A path to managed PostgreSQL and object storage when operational needs grow

## Expected scale

The baseline optimizes for tens to low thousands of users, not internet-scale
multi-region traffic. PostgreSQL, Rails web processes, and Solid Queue workers
can scale vertically and horizontally well beyond the expected initial load.
Scaling work should follow measured evidence.

## Deployment profiles

### Local development

- Rails and Vite under one browser origin where practical
- PostgreSQL in Docker or a local service
- Worker process when jobs are being exercised
- Local disk storage by default
- Deterministic seed users and fixture external providers

### exe.dev

- One persistent VM per application
- Docker Compose or equivalently simple supervised services
- One production OCI image with web and worker commands
- PostgreSQL isolated from the public network
- Local Active Storage on a persistent disk for small apps, with explicit
  off-VM backups
- Managed HTTPS/custom-domain proxy exposing only the Rails web port

exe.dev is the simplest fully owned profile, but ownership includes operating
PostgreSQL, upgrades, monitoring, and tested restores.

### Render

- The same image used for web, worker, and release/migration roles
- Managed PostgreSQL
- S3-compatible object storage for durable uploads
- Thin `render.yaml`

### Fly.io

- The same image used by web and worker machines
- Managed or external PostgreSQL
- S3-compatible object storage
- Thin `fly.toml`

### Cloud primitives

Deferred until an application needs them. The architecture should remain
compatible with a container runtime, PostgreSQL, object storage, and an OTLP
endpoint without shipping a premature Terraform/Kubernetes platform.

## Process topology

```text
web:      bin/rails server
worker:   bin/jobs
release:  bin/rails db:prepare
```

All roles use one image and codebase. A personal deployment may colocate them
on one VM. A PaaS may run them as separate process types.

## Operational ownership

Self-hosting is not free independence. Every owned deployment needs:

- automated encrypted PostgreSQL logical backups off the VM;
- backup coverage for local uploads;
- a documented and rehearsed restore procedure;
- OS, Ruby, Rails, database, and dependency updates;
- health checks and error visibility;
- credential rotation;
- capacity and disk monitoring.

Platform disk snapshots are useful but do not replace application-level
backups and restore drills.
