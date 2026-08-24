# Deployment and Operations

Status: accepted direction; scripts not implemented

Last updated: 2026-08-24

## Portable artifact

Build one production OCI image. Run it with role-specific commands:

```text
web:      bin/rails server
worker:   bin/jobs
release:  bin/rails db:prepare
```

Do not build host-specific application layers. Host files supply process,
network, volume, secret, and health configuration only.

## Planned repository artifacts

```text
Dockerfile
compose.yaml
.env.example
render.yaml                  # optional generated deployment recipe
fly.toml                     # optional generated deployment recipe
bin/docker-entrypoint
bin/deploy-exe
bin/backup
bin/restore
docs/deployment/
  exe-dev.md
  render.md
  fly.md
  generic-vps.md
  backups.md
```

Do not create these until implementation is approved.

## Compose topology

Development or exe.dev may colocate:

```text
public HTTPS proxy -> web
                       |
                private compose network
                   |              |
                worker        PostgreSQL
```

Only the web port is public. PostgreSQL must not bind to a public interface.
The worker uses the same image and environment as web with a different command.

## Data and storage

### PostgreSQL

- Local: Docker volume or local service
- exe.dev: private container/service on persistent disk for the simplest owned
  profile
- Render/Fly: managed or separately operated PostgreSQL
- Solid Queue initially uses the same logical database with its own tables and
  connection pool; split it only after measured contention or scaling evidence
- Production migrations: run `bin/rails db:prepare` once before updated web and
  worker processes, never hidden in every process startup

Use a Compose one-shot release container, Render pre-deploy command, or Fly
release command for that step. Evolve non-atomic schemas with an
expand/migrate/contract sequence so old and new processes can coexist during a
rolling release.

### Active Storage

- Development and small exe.dev apps: local disk
- Render/Fly and horizontally scaled apps: S3-compatible storage
- Upload metadata and ownership remain in PostgreSQL

## Backups

Minimum production requirements:

- scheduled `pg_dump` or equivalent logical backups;
- encryption before leaving the host;
- off-VM destination with retention;
- Active Storage backup when local disk is used;
- checksums and backup-failure visibility;
- documented restore into a disposable environment;
- periodic restore drill with application-level assertions.

A backup that has never been restored is not considered verified.

## Health and readiness

- Rails liveness endpoint that does not require external providers
- Readiness recipe checking database connectivity and migration compatibility
- Queue visibility and, when the integrations capability is installed,
  stale-operation visibility
- Health checks must not call Canvas, Google, or other third parties
- Deployment links and Amp services should expose health status

## Secrets

- Commit `.env.example` with key names and safe examples only.
- Ignore `.env.local`; use `dotenv-rails` in development and test only.
- Never expose secret values to Vite/browser variables.
- Deployment environment variables are canonical for provider and deployment
  secrets. Reserve Rails encrypted credentials for framework material where
  Rails expects them.
- Never support environment-variable and encrypted-credentials fallbacks for
  the same provider key.
- `bin/doctor` reports missing required key names without printing values.
- Keep non-secret provider settings separate where practical.
- Amp fixture mode works without provider secrets. Orb/workspace secrets are
  injected and are never written by `.agents/setup`.
- Use separate development/test/production credentials.

Every provider recipe documents the secret owner, configuration location,
required scopes, consumers, rotation procedure, overlap period, verification,
and rollback. Rotation cadence follows provider risk and capability; do not
invent a universal 90-day rule.

## Observability

Every profile:

- structured JSON production logs and container log-rotation guidance;
- request/job/operation correlation IDs;
- secret and sensitive-body redaction;
- `Rails.error` as the application-owned error-reporting boundary;
- health and queue visibility.

Sentry, Honeybadger, and similar services are optional adapters behind that
boundary.

OpenTelemetry is a separate capability, included by the `internal` profile and
absent from `minimal` and `personal`. It instruments Rails, Active Record,
Solid Queue, and Faraday. Telemetry exports only when an OTLP endpoint is
configured.

The internal/integrations capability records:

- provider request latency/count/status/retry metrics;
- rate-limit events;
- operation duration and outcome;
- queue latency and stale operation checks;
- optional OTLP export.

Do not hard-code a commercial observability vendor.

Initial retention guidance is 30 days for logs and 7 days for traces. Never log
provider response bodies. Audit-event retention is application-specific and
has no default deletion policy. Sensitive snapshots and uploads also require
an application-specific retention decision.

## Deployment-specific notes

### exe.dev

Use one VM per app unless evidence supports sharing. exe.dev's persistent disks,
Docker support, managed HTTPS/custom domains, and single proxied public port
fit the Compose topology. It has no public IP/private VM network assumptions to
build upon; keep PostgreSQL local/private.

### Render

Use web and worker services from the same image, managed PostgreSQL, a release
command, health check, and external S3-compatible storage. `render.yaml` should
remain readable and replaceable.

### Fly.io

Use web and worker process groups/machines from the same image. Keep volumes and
database topology explicit. Do not assume local file storage survives scaling
or machine replacement.

## Security defaults

- HTTPS-only production cookies and redirects
- Host allowlist and proxy-header configuration
- Rails CSRF and content-security policy
- No public database or queue ports
- Least-privilege provider credentials
- Fixed/configured provider base URLs to reduce SSRF risk
- Dependency and image scanning in CI
- Brakeman and authorization-negative tests
- Retention jobs for sensitive snapshots, logs, and uploads
