# Operations

Last updated: 2026-08-24

## Startup configuration

Copy the safe names from `.env.example` or `compose.env.example` into the
deployment's secret/configuration system. Run `bin/config-check` in the exact
production environment before release. It prints invalid **names**, never
values. `bin/release` validates and runs `db:prepare`; web and worker startup do
not migrate.

The application exits before startup when a selected mode is incomplete:

- local storage requires `ACTIVE_STORAGE_ROOT` on persistent storage;
- S3 storage requires bucket, region, and AWS-compatible access keys;
- SMTP requires address, port, and HELO domain;
- Google login requires client ID, secret, and Workspace domain allowlist.

## Email

Development Mailpit starts through `bin/dev`/the Amp service. Its SMTP endpoint
is private; its browser UI is only a captured-message review tool. Production
uses `MAIL_DELIVERY_METHOD=smtp` and normal Action Mailer SMTP variables, or
`none` for a deliberate operator-delivered invitation workflow. Google Workspace
SMTP relay is one valid SMTP endpoint; it is not application identity and no
Google mail code exists in core.

Own SMTP credentials in the deployment secret store. Grant only send/relay scope
for the configured sender/domain. Rotate by creating an overlapping credential
when supported, replacing the deployment secret, running `bin/config-check`,
sending a non-sensitive test, then revoking the old credential. Roll back by
restoring the prior still-valid secret during the overlap. Never test with a
production recipient list.

## Storage

Local storage is appropriate for one persistent VM. Mount `ACTIVE_STORAGE_ROOT`
into both web and worker. S3-compatible storage is required for ephemeral or
horizontally scaled hosts. Scope access to the one application bucket and
required object operations; avoid account-wide object-store keys.

The `s3-test` Compose profile is compatibility infrastructure only. MinIO's
upstream image is archived and is not a production recommendation. A deployed
S3-compatible service must provide its own versioning, backup, retention,
restore, and credential-rotation runbook. The local `bin/backup` intentionally
does not copy a remote bucket.

## Backup

For local Active Storage:

```text
DATABASE_URL=... ACTIVE_STORAGE_ROOT=/persistent/storage \
BACKUP_ROOT=/persistent/backups bin/backup
BACKUP_ROOT=/persistent/backups BACKUP_RETENTION_COUNT=14 bin/backup-prune
```

Schedule both commands outside the application process. Copy completed backup
directories to encrypted off-VM storage, monitor command failure, and set
retention for the application's actual legal and recovery requirements. The
archive checksum detects corruption but is not encryption. Database and local
files are captured sequentially, so workflows requiring a transactionally
consistent point-in-time snapshot should quiesce file mutation or use
coordinated volume/database snapshots.

## Restore and drill

Restore is intentionally explicit and destructive:

```text
RESTORE_DATABASE_URL=... \
RESTORE_CONFIRM_DATABASE=exact_target_database_name \
RESTORE_STORAGE_ROOT=/exact/restore/storage \
RESTORE_CONFIRM_STORAGE_ROOT=/exact/restore/storage \
bin/restore /path/to/backup
```

The target database must already exist. The script verifies archive checksums,
rejects unsafe storage paths, and refuses a target URL identical to
`DATABASE_URL`. Stop web/worker processes before a real replacement, restore,
run `bin/config-check`, start the release role, then verify owner login, a known
record, an uploaded object, `/ready`, and worker heartbeat.

Run a non-destructive drill against the currently configured PostgreSQL server:

```text
DATABASE_URL=... bin/restore-drill /path/to/backup
```

It creates a uniquely named disposable database and temporary storage root, runs
the real restore command, checks schema/foundation tables and file shape, then
removes both targets. A backup is not considered verified until this drill
passes on the database major and runtime used for recovery.

## Upgrade and rollback

Back up and complete a restore drill before framework, database-major, or
storage-adapter upgrades. Deploy additive schema changes first, run the release
role once, then update web and worker from the same immutable image. Contracting
changes require a later release after old processes are gone. Roll back to the
previous image only while its code remains compatible with the migrated schema;
otherwise restore the rehearsed backup into a replacement environment and switch
traffic after verification.
