# Internal-Tools Integration Research

Status: repositories inspected 2026-08-24

Sources:

- <https://github.com/robertguss/LX-Internal-Tools-Platform>
- <https://github.com/robertguss/wts-student-success-internal-tools>

## Product pattern

Both repositories serve authenticated staff operating bounded workflows. They
do not support customer multi-tenancy or need a cross-department RBAC platform.

Common flow:

1. Staff select terms, files, records, or an operation.
2. The application reads authoritative institutional APIs.
3. Meaningful pulls become snapshots or durable run records.
4. Some tools issue commands in external systems.
5. The UI reports progress, partial results, and operator identity.

## WTS Student Success

Primary workflows:

- Canvas terms/courses/enrollments produce at-risk student snapshots.
- Populi's REG NC marker produces withdrawal-risk tracking.
- A Populi Data Slicer CSV becomes an outstanding-balances snapshot.
- Staff-owned cases and immutable case actions span the Canvas and Populi
  observations.

Representative evidence:

- Canvas risk pull and persistence:
  [`convex/riskPulls.ts`](https://github.com/robertguss/wts-student-success-internal-tools/blob/main/convex/riskPulls.ts)
- Canvas pagination/retries:
  [`convex/canvasApi.ts`](https://github.com/robertguss/wts-student-success-internal-tools/blob/main/convex/canvasApi.ts)
- Populi pacing/rate limiting:
  [`convex/lib/populiRateLimiter.ts`](https://github.com/robertguss/wts-student-success-internal-tools/blob/main/convex/lib/populiRateLimiter.ts)
- Background balances snapshot:
  [`convex/outstandingBalances.ts`](https://github.com/robertguss/wts-student-success-internal-tools/blob/main/convex/outstandingBalances.ts)
- Case audit actions:
  [`convex/cases.ts`](https://github.com/robertguss/wts-student-success-internal-tools/blob/main/convex/cases.ts)

Data remains canonical in Canvas/Populi, while the application owns reference
caches, historical snapshots, cases, statuses, and audit history.

## LX Internal Tools

Primary workflows:

- Mirror Canvas terms/courses/assignments into Airtable.
- Apply Airtable-authored assignment dates and module names back to Canvas.
- Fetch and derive Watermark Evalkit scores, cache them, and optionally mirror
  to Airtable.
- Import Populi CSV/XLSX data and enroll members in Circle spaces/tags.
- Read Populi data for reports and exports.

Representative evidence:

- Canvas/Airtable sync:
  [`convex/courseReset/sync.ts`](https://github.com/robertguss/LX-Internal-Tools-Platform/blob/main/convex/courseReset/sync.ts)
- Canvas external writes and per-item failure handling:
  [`convex/courseReset/update.ts`](https://github.com/robertguss/LX-Internal-Tools-Platform/blob/main/convex/courseReset/update.ts)
- Circle durable chunk processing:
  [`convex/circleEnroll/actions.ts`](https://github.com/robertguss/LX-Internal-Tools-Platform/blob/main/convex/circleEnroll/actions.ts)
- Circle run claims/outcomes:
  [`convex/circleEnroll/runs.ts`](https://github.com/robertguss/LX-Internal-Tools-Platform/blob/main/convex/circleEnroll/runs.ts)
- Evalkit cache/mirror flow:
  [`convex/evalkitReports/actions.ts`](https://github.com/robertguss/LX-Internal-Tools-Platform/blob/main/convex/evalkitReports/actions.ts)

Circle enrollment is the strongest validation workflow because it combines
upload preview/repair, actor attribution, duplicate detection, stale-run
handling, transactional cursor claims, bounded execution, chained work,
progress, and per-row results.

## Existing strengths

- Canvas Link-header and Populi page pagination
- Canvas/Populi/Circle/Watermark rate-limit and retry handling in several
  clients
- Bounded concurrency for Canvas requests
- Durable scheduled/background work for several pulls
- Run IDs, progress, status, and latest-successful snapshot behavior
- Atomic Circle chunk claiming and cursor commits
- Provider-side or application-side upsert/idempotency patterns
- Per-item continuation for some bulk external writes
- Good unit coverage of API quirks, pagination, throttling, parsing, and domain
  calculations
- Operator-friendly progress and failure reporting

## Gaps the starter should prevent

- Some clients have no explicit timeout or retry policy.
- Successful JSON is sometimes trusted through TypeScript casts without runtime
  shape validation.
- Several running records can become stale and block future work.
- Duplicate user submissions are inconsistently prevented.
- Ambiguous provider success after a timeout lacks a general reconciliation
  policy.
- Some Canvas/Airtable writes lack structured actor/target/before/after audit
  records.
- Older LX actions have inconsistent authentication checks.
- Process-local rate limiting does not coordinate across multiple workers.
- Whole-file/all-page accumulation can create memory pressure.
- There is no webhook path, replay inbox, or deduplication—but neither product
  currently needs one.
- No repository CI was observed in these two applications despite substantial
  tests.
- Logs lack consistent request/job/provider correlation and metrics.
- Sensitive student/financial snapshot retention is not explicitly defined.

## Architectural implications

Include in the selectable internal/integrations capability:

- safe configured HTTP client behavior;
- response parsing and provider-neutral error categories;
- Solid Queue patterns;
- durable operation status, idempotency, stale detection, and progress;
- structured audit events;
- polling progress UI;
- fixture provider mode and integration test support;
- structured logs and correlation;
- Active Storage import foundation.

Keep as optional provider/workflow recipes:

- Canvas, Populi, Airtable, Circle, and Watermark clients;
- CSV/XLSX preview and repair;
- reconciliation/mirror workflows;
- operation item outcomes/failure CSV;
- scheduled cursors;
- webhooks.

Do not add dynamic provider-account tables, a connector registry, generic
resource synchronization, or AI to the baseline.
