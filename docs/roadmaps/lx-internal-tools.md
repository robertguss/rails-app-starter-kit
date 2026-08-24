# LX Internal Tools Rebuild Roadmap

Status: proposed validation roadmap

Last updated: 2026-08-24

Read the [internal-tools research](../research/internal-tools.md) and
[integration architecture](../architecture/integrations.md) first.

## Objective

Rebuild LX Internal Tools on the internal profile while preserving operator
speed and improving ownership, portability, authorization, timeouts,
idempotency, auditability, testing, and operations.

The rebuild is not a mandate to turn every LX provider into a starter feature.

## Safety rules

- Existing LX remains available throughout validation.
- Start with sanitized fixtures and read-only calls.
- Provider writes require separate explicit approval, narrow test scope, and
  auditable actor/result records.
- Never log tokens, student records, full sensitive provider payloads, or
  imported spreadsheets.
- Decide retention for student/report data before production import.

## Phase L0 — Inventory and workflow contract

1. Inspect current code, schema, environment names, provider scopes, tests,
   production deployment, and operational docs directly.
2. Inventory each tool, owner, users, frequency, source of truth, provider
   account, read/write scope, data sensitivity, run duration, and recovery
   expectations.
3. Identify which Convex data is durable business history versus recomputable
   cache/log data.
4. Capture sanitized provider fixtures for successful and failure responses.
5. Define parity and intentional improvements per workflow.
6. Review provider terms and least-privilege credentials.

Gate: every production mutation and dataset has an owner, migration decision,
and safe test plan.

## Phase L1 — Generate internal profile and access

1. Generate with Google Workspace auth, explicit access grants, jobs,
   integrations, imports, storage, mail, audit, and observability.
2. Configure Workspace domain plus exact user grants.
3. Define owner/access administrator and whether all granted users may run
   external writes or a local operator permission is needed.
4. Import/grant only approved staff; do not create users on unauthorized Google
   callbacks.
5. Deploy fixture mode to a non-production Render environment.

Gate: access/revocation and development-agent flows pass; no provider
credentials are required for the fixture deployment.

## Phase L2 — Circle enrollment vertical slice

Circle is first because it exercises the broadest reusable workflow.

1. Upload Populi CSV/XLSX through Active Storage.
2. Parse in a background job with size/row bounds.
3. Present ready, dropped, and repairable rows before execution.
4. Create a durable operation and item outcomes.
5. Implement Circle member lookup/create/invite, space enrollment, and tag
   behavior in an app-local client.
6. Use bounded chunks, heartbeat, claims, idempotency/state comparison, and
   stale-run recovery.
7. Display durable progress, partial success, row outcomes, and failure export.
8. Audit actor, intended targets, provider identifiers, and sanitized outcomes.

Failure tests:

- timeout before response and ambiguous provider result;
- 429 with `Retry-After`;
- duplicate member/enrollment;
- malformed provider response;
- worker death between claim and commit;
- duplicate button click;
- one bad row among valid rows;
- stale run and operator retry.

Gate: fixture parity first, then an explicitly approved narrow provider test.

## Phase L3 — Evalkit and Airtable workflow

1. Implement Watermark client pagination/throttling/runtime parsing.
2. Reproduce derived course/instructor score calculations with fixture parity
   tests against the current app.
3. Cache immutable/ended projects and support intentional force-refresh.
4. Plan Airtable creates/updates/deletes before applying them.
5. Require confirmation for destructive reconciliation.
6. Persist actor, plan summary, per-batch outcomes, and partial-failure repair
   guidance.

Gate: generated score and mirror plans match current fixtures before live read
or write tests.

## Phase L4 — Canvas/Airtable course reset

1. Implement Canvas and Airtable clients with explicit timeouts, pagination,
   rate-limit policy, runtime parsing, and redacted logs.
2. Reproduce term/course/assignment mirror behavior.
3. Calculate desired assignment/module changes as a persisted dry-run plan.
4. Show exact target, before, after, skip, and warning counts.
5. Apply only after explicit confirmation and authorization.
6. Compare current versus desired state before each provider write.
7. Persist per-item outcomes and support safe reconciliation/resume rather than
   blind bulk retry.

Gate: approved shadow/read-only comparison, then a deliberately limited live
write test with rollback/reconciliation plan.

## Phase L5 — Populi reports and remaining tools

1. Implement only the Populi endpoints actually used by LX.
2. Preserve academic-year/reference caching and report transforms.
3. Queue substantial pulls and retain latest-successful snapshots when history
   matters.
4. Stream generated exports rather than holding unnecessary whole datasets in
   browser memory.
5. Complete remaining documented workflows one vertical slice at a time.

Gate: explicit parity matrix identifies complete, changed, and intentionally
retired tools.

## Phase L6 — Data migration and production rehearsal

1. Export durable users/access, cached scores, run history, or audit data that
   must survive; recompute disposable caches instead of migrating everything.
2. Transform provider IDs and timestamps into the Rails schema with checksums
   and count reconciliation.
3. Rehearse against a restored/sanitized production snapshot.
4. Deploy web/worker/release roles to Render with managed PostgreSQL and
   S3-compatible storage.
5. Verify queue interruption, stale-operation alert, backup, and restore.
6. Run read-only/shadow comparisons with the existing application.

Gate: operator acceptance, data reconciliation, rollback plan, and explicit
approval for production cutover and provider writes.

## Phase L7 — Cutover and starter feedback

1. Freeze/migrate necessary state in a controlled window if required.
2. Switch staff to the replacement while preserving the old app for rollback.
3. Monitor provider errors, 429s, job latency, stale operations, and audit
   outcomes.
4. Retire old deployment only under separate approval after the rollback window.
5. Classify friction and reusable code.

Likely recipe candidates after evidence:

- CSV/XLSX preview/repair and operation items
- Canvas client pagination/throttling
- Populi pacing/report parsing
- Airtable batch/reconciliation
- Circle resumable enrollment
- Watermark parsing/cache

School-specific IDs, thresholds, report names, score formulas, course-reset
rules, and workflow UI remain in LX.

## Acceptance summary

- Google identity maps into first-party users/sessions and explicit grants
- Provider secrets live only in deployment configuration
- Every external request has timeout and safe error handling
- Runtime response validation at provider boundaries
- Durable, idempotent, actor-attributed jobs
- Confirmation and structured audit for consequential writes
- Partial failures and retries are operationally understandable
- Fixture mode and CI need no live provider credentials
- Render deployment has tested backup/restore and worker recovery
- Existing app remains rollback until explicit retirement
