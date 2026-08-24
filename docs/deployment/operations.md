# Deployment operations

## Secrets

For every secret record its human owner, canonical host secret-store location,
least-privilege scope, and consuming roles. Use separate environment
credentials. Rotate by issuing an overlapping credential where supported, update
web/worker, run `bin/config-check`, verify a narrow non-sensitive operation,
then revoke the old credential. During overlap, rollback means restoring the
still-valid old value and image. If overlap is impossible, define an outage and
recovery plan. Never print values or expose them to browser/Vite variables.

## Backups and drills

Run the existing backup/prune tools on a schedule. Encrypt before transfer,
store copies off-host in a separately controlled account, monitor failures and
checksums, and choose retention from recovery/legal needs rather than a
universal number. Back up local uploads; separately protect/version remote
buckets. Run `bin/restore-drill` periodically against a disposable target
matching the production PostgreSQL major version, then verify login, known
records, files, readiness, and worker health. Record date, artifact, operator,
and result.

## Upgrade and rollback

Pin an immutable image digest. Back up and drill first. Use
expand/migrate/contract: deploy additive schema, run `bin/release` exactly once,
roll web and worker together, backfill safely, and remove old schema only in a
later release after old code is gone. An image rollback is safe only while the
new schema remains backward-compatible. Otherwise restore the rehearsed backup
to a replacement environment and switch traffic after verification. Database
major and storage-adapter changes require their own rehearsed migration plan.
