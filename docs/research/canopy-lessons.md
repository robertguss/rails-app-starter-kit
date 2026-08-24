# Canopy Lessons

Status: synthesized from Canopy design work

Last updated: 2026-08-24

Canopy supplied a strong provider-neutral TypeScript architecture, but it is an
informed source of principles rather than a requirement for this starter.

## Canopy direction

- pnpm workspace monorepo
- React + Vite + TypeScript frontend
- React Router Data Mode
- TanStack Query for server state and Zustand for client-owned UI state
- Fastify modular-monolith API
- OpenAPI 3.1 schemas and generated TypeScript client
- PostgreSQL + Drizzle
- pg-boss durable jobs
- S3-compatible object storage
- PostgreSQL full-text search; pgvector only when justified
- provider-neutral boundaries for auth, email, storage, AI, billing, and other
  integrations
- Vitest, Testing Library, Playwright
- server-first OpenTelemetry

## Lessons retained

### Modular monolith before services

Keep product domains coherent in one codebase and database. Separate web and
worker processes for operations, not independent microservices by default.

Rails adapts this lesson through conventional models, controllers, jobs, and
domain services rather than Fastify packages.

### Application-owned identity

Canopy owns users, workspaces/memberships, and opaque server-side sessions;
external identity maps into them. The successor keeps the same durable
principle while removing workspaces/memberships from its bounded-app baseline.

### Provider payloads stop at adapters

External credentials, request schemas, and raw responses should remain in
integration boundaries. The application records its own stable identifiers,
normalized facts, operations, and audit history.

### Durable jobs need idempotency and reconciliation

PostgreSQL-backed jobs simplify infrastructure and can coordinate with domain
state, but delivery is not magic exactly-once execution. External effects still
need idempotency keys, claims, before/after state comparisons, and
reconciliation after ambiguous failures.

### Evidence gates

Canopy deliberately deferred hosting vendors, production provider calls,
collaborative editing, approximate vector indexes, and other decisions until
evidence justified them. The starter adopts this as a promotion rule.

### Search progression

Use PostgreSQL filtering and full-text search first. Add vector search only when
semantic retrieval quality and volume justify its operational and filtering
cost.

### Provider-neutral observability

Structured logs and server-first telemetry should describe application and
integration behavior without making one commercial vendor part of the domain.

### Verification is part of architecture

Fresh database migrations, contract drift checks, tests, production builds, and
browser journeys establish capability. Local compilation alone does not prove
production readiness.

## Lessons adapted rather than copied

| Canopy choice | Starter adaptation |
|---|---|
| pnpm workspace | pnpm for frontend assets; no workspace without a second real package |
| React Router Data Mode | Inertia visits and Rails controllers |
| TanStack Query | Optional for independent polling/caching, not ordinary page state |
| Zustand | Optional for complex cross-component UI state |
| Fastify API | Rails controllers and domain workflows |
| OpenAPI generated client | Deferred until a real non-Inertia client or public API exists |
| Drizzle | Active Record and Rails migrations |
| pg-boss | Solid Queue |
| Separate static web/API | One Rails web application plus worker |
| Workspace authorization | Simple app access grants; app-specific roles only when needed |

## Lessons not promoted automatically

- A provider interface does not imply every provider belongs in the starter.
- An AI adapter seam does not justify shipping an AI dependency.
- OpenTelemetry value does not require every minimal personal app to ship every
  instrumentation gem; profile-level selection remains under review.
- TypeScript compile-time guarantees do not remove runtime validation of
  external data; Ruby boundaries must be equally explicit.
