# Third-Party Integration Architecture

Status: accepted direction and implementation defaults

Last updated: 2026-08-24

## Goal

Make the common internal-tool workflows fast and safe without inventing a
generic connector framework.

The repeated shape is:

```text
approved user -> validate/preview -> durable operation -> provider client
              -> progress/outcomes -> application snapshot or external command
```

## Code ownership

Installed integration code is ordinary app-local Rails code:

```text
app/services/integrations/
  canvas/
    client.rb
    configuration.rb
    errors.rb
    parsers/
  populi/
    client.rb
    configuration.rb
    parsers/

app/jobs/
  canvas_risk_pull_job.rb
```

Do not require each provider to implement a generic CRUD/resource interface.
Canvas pagination, Populi pacing, Circle tags, Watermark envelopes, and Airtable
batch rules are appropriately provider-specific.

## HTTP foundation

The baseline is Faraday plus retry middleware, with common middleware or a small
configured factory providing:

- explicit connect, read, and write timeouts;
- bounded exponential backoff with jitter;
- `Retry-After` support;
- retries only for safe/idempotent requests or idempotency-protected writes;
- request, operation, and provider correlation IDs;
- response body-size limits;
- authorization/header/body redaction;
- structured duration/status/retry instrumentation;
- deterministic test adapters.

Provider configuration should assume one institutional account per app
deployment unless evidence requires account tables or OAuth connection UI.

## Boundary validation

External responses are untrusted even when HTTP status is successful.

- Parse required fields explicitly.
- Normalize provider nullability and types.
- Return small Ruby `Data` objects where useful.
- Preserve provider IDs without making raw provider payloads the application
  model.
- Raise safe categorized errors with sanitized context.

Start with explicit parsers. Add a validation library only when it removes
meaningful repetition; do not add `dry-schema` initially.

## Shared error categories

The integrations capability may define a small hierarchy:

- `ConfigurationError`
- `AuthenticationError`
- `AuthorizationError`
- `RateLimited` with retry time
- `Timeout`
- `Unavailable`
- `InvalidResponse`
- `Conflict` or `Duplicate`
- `NotFound`
- `PermanentRequestError`

Provider status codes and message quirks are translated locally into these
categories. Do not expose provider secrets or full sensitive response bodies in
exceptions shown to users.

## Data strategy

Choose deliberately per workflow:

| Strategy              | Use when                                                                          |
| --------------------- | --------------------------------------------------------------------------------- |
| Live fetch            | Small current lookup where latency and availability are acceptable                |
| Reference cache       | Stable lists such as terms, projects, or spaces improve selectors and API usage   |
| Durable snapshot      | Staff need historical reports, latest-successful fallback, or workflow continuity |
| Derived cache         | Traversal/calculation is expensive and source changes slowly                      |
| Mirror/reconciliation | Another system explicitly needs a maintained copy                                 |

Provider-native business objects normally remain canonical remotely. The app
owns its snapshots, cases, operation state, annotations, and audit history.

## Durable operations

The `integrations` capability should install an `operations` model with:

- `kind`, `status`, `actor_id`, optional `idempotency_key`, and `current_step`;
- progress current and total;
- safe request and result summaries;
- error category and safe message;
- heartbeat, started, and finished timestamps.

Enforce a unique `(kind, idempotency_key)` constraint when an idempotency key is
present.

Suggested status vocabulary:

```text
pending -> running -> succeeded
                   -> partially_succeeded
                   -> failed
                   -> cancelled (only if cancellation is truly implemented)
```

An optional `operation_items` recipe supports per-row outcomes and failure CSVs
for batch tools.

Use durable operation state and stale-heartbeat checks. Solid Queue jobs must
use database constraints or explicit claims to prevent duplicate work. Do not
apply blanket retries: retry categorized transient failures only with bounded
exponential backoff and jitter, respect `Retry-After`, and default to five
attempts for safe transient work. Discard permanent authentication, request, and
configuration failures; leave unknown failures visible and failed. An ambiguous
provider mutation must not be retried unless a provider idempotency key or state
reconciliation makes that retry safe.

The integrations capability shares one sanitized `audit_events` table with
authentication and access administration. External commands record actor,
target, sanitized intent, and outcome there rather than creating a second audit
subsystem.

## User-triggered external writes

Each command must answer:

1. Who is authorized: any active member, owner/admin, or app-specific operator?
2. Is a preview/dry run possible?
3. What exactly will change?
4. How is duplicate submission prevented?
5. What provider identifier or idempotency key is retained?
6. How are partial success and safe retry reported?
7. What audit record captures actor, target, sanitized intent, and outcome?

For consequential bulk changes, planning and confirmation should be separate
durable steps rather than one button that immediately mutates the provider.

## Progress UX

Baseline behavior can use polling:

1. POST validates and creates an operation.
2. Response redirects or returns the operation ID.
3. React polls a small same-origin JSON status endpoint every two seconds while
   the operation is active, backing off toward ten seconds.
4. Polling pauses while the page is hidden, resumes when visible or reloaded,
   and stops when the operation reaches a terminal state.
5. The page remains useful across reloads.
6. Latest successful data stays visible when a refresh fails.
7. Batch tools expose row-level failures and downloadable remediation data.

SSE is an optional recipe. WebSockets are unnecessary for the current evidence.
The JSON status endpoint is an application endpoint, not a commitment to a
public API, OpenAPI client, or TanStack Query.

## Concurrency and provider pacing

Use Solid Queue concurrency limits for ordinary concurrent work. When a provider
enforces a strict account-wide quota across workers, coordinate it with a
PostgreSQL-backed lease or token bucket. Provider-specific quota rules remain in
provider recipes. Never rely on in-memory rate limiting for a shared account
quota across processes.

## Files, imports, and exports

The optional import recipe should:

- upload through Active Storage;
- retain original filename, size, checksum, actor, and operation;
- parse in a background job;
- provide preview, validation errors, dropped-row reasons, and confirmation;
- cap file size and row count;
- defend against formula injection in generated CSV;
- define retention and permanent deletion.

## Testing and local development

Every provider recipe should include:

- fixture responses with secrets and personal data removed;
- pagination, rate-limit, timeout, malformed-response, and authentication tests;
- idempotency and concurrency tests for writes;
- authorization negative tests;
- browser coverage for preview, duplicate click, progress, partial failure, and
  retry;
- a fixture-provider mode usable in CI and Amp Orbs without live credentials.

Live provider tests should be explicit, read-only where possible, and never part
of normal CI.

## Optional recipes, not baseline

- Canvas Link pagination and 403 throttling
- Populi `parameters` encoding, pacing, and Data Slicer reports
- Airtable offset pagination, ten-row batching, and reconciliation
- Circle resumable enrollment
- Watermark result parsing and frozen-project caching
- Webhook verification, delivery inbox, deduplication, and replay
- Recurring cursor/watermark synchronization
- Multi-account OAuth connections
- AI provider adapters
