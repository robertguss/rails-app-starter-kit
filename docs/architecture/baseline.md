# Recommended Baseline Architecture

Status: accepted direction with proposed implementation details

Last updated: 2026-08-24

## Stack

| Layer | Baseline |
|---|---|
| Language/framework | Ruby on Rails modular monolith |
| Browser UI | React 19 + TypeScript through Inertia Rails |
| Asset development | Vite |
| Styling | Tailwind CSS 4, shadcn/ui New York style, Neutral base, Radix, Lucide, CSS variables, dark mode |
| Database | PostgreSQL |
| Persistence | Active Record and Rails migrations |
| Jobs | Active Job with Solid Queue |
| Files | Active Storage |
| Email | Action Mailer |
| Ruby tests | Minitest |
| Frontend tests | Vitest + React Testing Library |
| Browser tests | Playwright |
| Quality/security | RuboCop, Brakeman, dependency audits, TypeScript, ESLint/Prettier |
| Packaging | One production OCI image; Bundler + pnpm lockfiles |

Exact stable versions must be checked from authoritative sources when
implementation starts rather than pinned from this design document.

## Why a Rails monolith

The target applications do not inherently need a browser SPA, a public API,
and an independently deployed backend. Rails can own HTTP, identity, data,
jobs, files, and email while Inertia supplies React pages with typed props.

```text
Browser
  |
  v
Rails controllers ----> Inertia React pages
  |                         |
  +--> domain/services      +--> local interaction state
  |
  +--> PostgreSQL / jobs / files / mail / integrations
```

This removes:

- duplicate browser/API authentication flows;
- OpenAPI generation for internal page props;
- a separate Node API and worker framework;
- client cache invalidation for ordinary mutations;
- provider-specific hosted backend requirements.

It preserves a future JSON API boundary: add explicit API controllers and an
OpenAPI contract only when another client or external consumer exists.

## Modular-monolith boundaries

Use Rails conventions first. Add module namespaces around coherent product
domains, not around technical abstractions.

Illustrative structure:

```text
app/
  controllers/
  models/
  jobs/
  mailers/
  policies/              # only if a real app needs policy objects
  integrations/          # installed by the integrations capability
  frontend/
    components/
      ui/
    layouts/
    pages/
    hooks/
    lib/
    types/
    entrypoints/
```

Avoid a second frontend root, generic repository layers over Active Record, or
a dependency-injection container. A domain service is justified when it owns a
real workflow or transaction, not merely to wrap a model call.

## Inertia data model

- Controllers authorize, load data, and pass explicit serializable props.
- TypeScript page-prop types remain close to the page or in generated/shared
  definitions only when reuse justifies it.
- Inertia visits and form helpers own ordinary server-state transitions.
- Local React state owns ephemeral interaction state.
- TanStack Query is optional for a page that truly needs independent polling,
  caching, or high-frequency remote state.
- Zustand is optional for complex client-owned state spanning distant
  components. It is not a baseline global store.
- Production SSR is disabled by default.

## PostgreSQL usage

PostgreSQL is the default in all supported profiles because the same schema can
run with colocated web/worker processes on a VM or managed services on a PaaS.

Use:

- foreign keys, unique constraints, and check constraints for durable
  invariants;
- transactions around related domain writes;
- normal Rails migrations and `db:prepare` in the release role;
- PostgreSQL full-text search before an external search service;
- pgvector only after measured semantic-search requirements.

SQLite remains a possible later tiny-app recipe, not a v1 compatibility burden.

## Background work

Solid Queue is the durable execution baseline. Jobs must be:

- idempotent or explicitly non-retryable;
- safe under process interruption;
- correlated with the initiating user and operation where relevant;
- bounded by timeout/concurrency policies for external APIs;
- observable through logs and durable status for user-facing work.

Not every API read should become a job. Small live reads can stay synchronous;
imports, reports, mirrors, and external mutations should normally be queued.

## Files and email

- Active Storage uses local disk in development and small owned-VM profiles.
- Render/Fly use S3-compatible object storage.
- File workflows validate content type, size, checksum, ownership, and
  retention; browser-supplied MIME is not trusted alone.
- Action Mailer is the owned email boundary. SMTP is the portable default;
  provider adapters remain optional.

## Minimal UI baseline

Include a restrained, proven shadcn component set rather than the entire
registry. The initial shell should cover:

- buttons, inputs, labels, forms, and validation messages;
- dialogs, dropdowns, sheets, tooltips, alerts, and toasts;
- cards, tables, badges, tabs, skeletons, and progress;
- accessible navigation, responsive layout, dark mode, error, empty, and 404
  states.

Install specialized charts, editors, calendars, command palettes, or drag/drop
only when an app needs them.
