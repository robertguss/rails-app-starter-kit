# Phase 6 Implementation Record

Status: implemented

Implemented: 2026-08-24

## Outcome

The build-time `internal` profile now installs a provider-neutral integrations
foundation. The runnable source, `minimal`, and `personal` outputs remain free
of integration models, Faraday, OpenTelemetry, provider environment keys, and
provider behavior. The only adapter in the starter is an in-memory fake provider
used to prove the architecture without credentials or institutional systems.

The generated internal application owns ordinary Rails code for:

- a fixed-HTTPS Faraday boundary with connect/read/write timeouts, bounded
  exponential retry, `Retry-After`, response-size limits, idempotency-protected
  writes, correlation headers, and metadata-only logs;
- immutable `Data` responses and explicit parsers for untrusted payloads;
- configuration, authentication, authorization, rate-limit, transport, protocol,
  validation, provider, conflict, and ambiguous-write errors;
- durable operations with actor, status, idempotency, progress, sanitized
  summaries/errors, claims, heartbeats, stale reclaim, and audit events;
- optional per-record operation items, installed separately by the internal
  profile for partial outcomes and interruption recovery;
- a Solid Queue fixture job with a per-actor concurrency limit and five-attempt
  transient retry policy;
- PostgreSQL-locked shared provider pacing;
- owner-only operation start/list/show/status endpoints and a responsive React
  progress page that survives reload, polls every two seconds, backs off failed
  polls to ten seconds, pauses while hidden, and stops at terminal state; and
- optional OTLP export with Rails, Active Record, Active Job/Solid Queue, and
  Faraday instrumentation. No exporter is initialized without an endpoint.

## Fake-provider proof

The deterministic adapter pages three records and performs individually
idempotent writes. Its simulations cover timeout, rate limit, authentication,
malformed payload, partial validation failure, ambiguous mutation outcome, and
worker interruption. Tests prove duplicate submission suppression, bounded
retry, terminal classification, per-item partial success, claim ownership, stale
reclaim and resume, persistent shared pacing, owner authorization, structured
audit, and secret redaction.

This is a reference vertical slice, not a generic connector runtime. A generated
application replaces or adds app-owned adapters for its actual providers; no
Canvas, Populi, Airtable, Circle, or Watermark behavior is installed.

## Deliberate adjustments

- Integration services live under `app/services/integrations`, not a custom
  autoload root. This follows Rails/Zeitwerk ownership while preserving the
  architecture's explicit provider namespaces.
- `operation_items` remains a distinct capability but is selected by the
  `internal` profile because the required partial/interrupted fixture proof is a
  coherent batch workflow.
- The OpenTelemetry Active Job instrumentation covers Solid Queue jobs through
  Rails' job boundary; no queue-specific vendor agent is introduced.
- Shared pacing is a PostgreSQL locked reservation rather than a generalized
  token-bucket framework. It demonstrates the cross-worker invariant with less
  machinery; provider recipes can replace the interval rule when evidence
  requires bursts or multiple quota windows.

## Verification contract

The internal generated-app suite exercises the full fake-provider lifecycle and
the normal canonical checks: Minitest, TypeScript, ESLint, Prettier, Vitest,
production assets/eager load, Brakeman, dependency audits, and Playwright. The
profile matrix retains strict negative assertions for integration code and
institutional provider names in `minimal` and `personal`.
