# Recommended Baseline Architecture

Status: accepted direction and implementation defaults

Last updated: 2026-08-24

## Stack

| Layer              | Baseline                                                                                        |
| ------------------ | ----------------------------------------------------------------------------------------------- |
| Language/framework | Ruby on Rails modular monolith                                                                  |
| Browser UI         | React 19 + TypeScript through Inertia Rails                                                     |
| Asset development  | Vite                                                                                            |
| Styling            | Tailwind CSS 4, shadcn/ui New York style, Neutral base, Radix, Lucide, CSS variables, dark mode |
| Database           | PostgreSQL                                                                                      |
| Persistence        | Active Record and Rails migrations                                                              |
| Jobs               | Active Job with Solid Queue                                                                     |
| Files              | Active Storage                                                                                  |
| Email              | Action Mailer                                                                                   |
| Ruby tests         | Minitest                                                                                        |
| Frontend tests     | Vitest + React Testing Library                                                                  |
| Browser tests      | Playwright                                                                                      |
| Quality/security   | RuboCop, Brakeman, dependency audits, TypeScript, ESLint/Prettier                               |
| Packaging          | One production OCI image; Bundler + pnpm lockfiles                                              |

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
- Define explicit TypeScript page-prop interfaces beside their pages. Do not
  add Ruby-to-TypeScript generation initially.
- Use Inertia forms and Rails validation errors for ordinary forms. Do not add
  React Hook Form or Zod unless a specific interactive form justifies duplicate
  client-side validation.
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

Solid Queue is the durable execution baseline. It initially uses the same
logical PostgreSQL database as the application with its own tables and
connection pool. Move it to a separate database only after measured contention
or scaling evidence.

Jobs must be:

- idempotent or explicitly non-retryable;
- safe under process interruption;
- correlated with the initiating user and operation where relevant;
- bounded by timeout/concurrency policies for external APIs;
- observable through logs and durable status for user-facing work.

Not every API read should become a job. Small live reads can stay synchronous;
imports, reports, mirrors, and external mutations should normally be queued.

Do not apply blanket retries. Retry categorized transient failures only with
bounded exponential backoff and jitter, respecting `Retry-After`; use five
attempts as the initial default for safe transient work. Discard permanent
authentication, request, and configuration failures. External writes require
idempotency or reconciliation before retry. Unknown failures remain visible
and failed, and ambiguous external mutations are never blindly retried.

## Files and email

- Active Storage uses local disk in development and small owned-VM profiles.
- Render/Fly use S3-compatible object storage.
- MinIO is an optional Compose/CI compatibility profile, not a mandatory local
  service. Normal tests use disk or SDK stubs as appropriate.
- File workflows validate content type, size, checksum, ownership, and
  retention; browser-supplied MIME is not trusted alone.
- Action Mailer with generic SMTP is the owned, portable email boundary.
  Google Workspace SMTP relay works through that configuration; Postmark,
  Resend, SES, and other delivery providers remain optional recipes.
- Development uses Mailpit, and tests use the Action Mailer test adapter.

## Minimal UI baseline

Install only this restrained shadcn component set in the baseline:

```text
alert, avatar, badge, button, card, checkbox, dialog, dropdown-menu,
input, label, progress, select, separator, sheet, skeleton, sonner,
table, tabs, textarea, tooltip
```

The shell also includes accessible navigation, responsive layout, dark mode,
and error, empty, loading, and 404 states. Calendars, charts, command palettes,
editors, drag/drop, and generic data-table abstractions are not baseline
dependencies; install them only for an application that needs them.
