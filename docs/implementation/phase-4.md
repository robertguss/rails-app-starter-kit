# Phase 4 Implementation Record

Status: implemented

Implemented: 2026-08-24

## Outcome

The runnable source application now has Rails-native jobs, files, and email; one
portable production image; an owned-VM Compose topology; startup configuration
validation; and destructive-action-gated backup/restore tools. These facilities
add no hosted application-provider requirement.

Solid Queue 1.7.0 and application tables live in the same logical PostgreSQL
database. Solid Queue still establishes its own Rails connection pool through
its `primary` connection declaration. A second physical queue database was
removed because it contradicted the accepted small-application topology. A split
remains an operational optimization that requires measured contention,
availability, or scale evidence.

## Selected versions

Direct dependencies remain exact in both manifests and lockfiles.

| Facility                 |                      Version | Source and reason                                                                                                                                                   |
| ------------------------ | ---------------------------: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Solid Queue              |                        1.7.0 | Existing exact Phase 2 dependency; its generated schema was moved unchanged into a normal reversible primary migration.                                             |
| AWS S3 SDK               |                      1.229.0 | [RubyGems](https://rubygems.org/gems/aws-sdk-s3/versions/1.229.0); current stable S3-compatible Active Storage client when implemented.                             |
| Image Processing         |                        2.0.3 | [RubyGems](https://rubygems.org/gems/image_processing/versions/2.0.3); current stable Active Storage variant pipeline.                                              |
| ruby-vips                |                        2.3.0 | [RubyGems](https://rubygems.org/gems/ruby-vips/versions/2.3.0); current stable binding for the lower-memory libvips processor.                                      |
| Mailpit                  |                       1.30.7 | [Mailpit releases](https://github.com/axllent/mailpit/releases/tag/v1.30.7); pinned development binary and container.                                               |
| PostgreSQL Compose image |               15.19-bookworm | [PostgreSQL 15.19](https://www.postgresql.org/docs/release/15.19/) is the current supported minor in the major used for local verification.                         |
| Optional MinIO fixture   | RELEASE.2025-09-07T16-13-09Z | Last published official container release. The upstream community repository and image are archived, so this profile is test-only, not a production recommendation. |

## Runtime topology

`Dockerfile` has a Node build stage but no Node executable, package tree, or SSR
process in the final Ruby runtime stage. The same image supports:

```text
release  bin/release       validates configuration, runs db:prepare once
web      bin/rails server  serves HTTP after release succeeds
worker   bin/jobs start    executes Solid Queue after release succeeds
```

Compose keeps PostgreSQL private, gives local Active Storage a shared persistent
volume, and publishes only web. Mailpit and MinIO are opt-in development/test
profiles. Host recipes must continue to supply only process, network, volume,
secret, release, and health configuration around this image.

## Jobs, files, and mail

- `PurgeExpiredSessionsJob` is idempotent, retries only a categorized database
  connection failure with a bounded polynomial backoff, and discards stale
  serialized records. There is no blanket retry policy.
- `/ready` checks the primary database, pending migrations, and Solid Queue
  schema without calling an external service. `bin/worker-health` requires a
  recent Solid Queue process heartbeat.
- Active Storage uses disk in development/test and supports an explicit
  S3-compatible endpoint, region, path style, and bucket in production. The
  upload flow proves authenticated upload, owner-only download, and purge.
- Development SMTP goes to supervised Mailpit. Tests use Rails' test adapter.
  Production supports either intentionally disabled delivery or generic SMTP;
  invitations are queued only when delivery is configured.

## Configuration and recovery

`bin/config-check` validates production key names, URL/host forms, selected
authentication/storage/mail modes, and mode-specific required names without
printing values. Every production image command runs it through
`bin/docker-entrypoint`; `bin/release` then performs the only automatic
migration step.

`bin/backup` atomically captures a custom-format PostgreSQL dump plus local
Active Storage archive and checksums. `bin/restore` verifies checksums and
requires exact database and storage-path acknowledgements before replacement.
`bin/restore-drill` creates and destroys a disposable database and asserts the
restored migration, user, queue, file-metadata, and storage shape.
`bin/backup-prune` applies count-based local retention. The complete operator
contract and S3 limitation are in [Operations](../operations.md).

## Direct verification

Phase 4 was exercised from newly dropped development and test databases. Both
new migrations were run forward, backward, and forward again. Focused tests
cover uploads, mail/no-mail grants, runtime configuration, readiness, and the
idempotent maintenance job. The backup archive was restored into a disposable
database and temporary storage directory and all assertions passed.

Container build/run and Compose evidence is recorded with the final Phase 7
deployment validation because those phases share the same image.
