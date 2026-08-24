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
- Production migrations: explicit release command, never hidden in every web
  process startup

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
- Separate queue/stale-operation visibility
- Health checks must not call Canvas, Google, or other third parties
- Deployment links and Amp services should expose health status

## Secrets

- Commit `.env.example` with key names and safe examples only.
- Never expose secret values to Vite/browser variables.
- Use deployment environment variables or Rails encrypted credentials with a
  deployment-provided master key.
- Validate required key names at boot for installed features without printing
  values.
- Keep non-secret provider settings separate where practical.
- Document rotation and use separate development/test/production credentials.

The implementation phase must settle whether environment variables are the
canonical provider-secret source with credentials reserved for Rails core, or
whether both use a documented precedence rule.

## Observability

Every profile:

- structured production logs;
- request/job/operation correlation IDs;
- secret and sensitive-body redaction;
- actionable unhandled-error reporting hook;
- health and queue visibility.

Internal/integrations capability:

- provider request latency/count/status/retry metrics;
- rate-limit events;
- operation duration and outcome;
- queue latency and stale operation checks;
- optional OTLP export.

Do not hard-code a commercial observability vendor.

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
