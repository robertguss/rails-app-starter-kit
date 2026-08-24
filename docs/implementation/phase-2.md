# Phase 2 Implementation Record

Status: implemented

Implemented: 2026-08-24

## Outcome

The repository now has one deterministic command contract for humans, CI, and
Amp Orbs:

```text
bin/setup
bin/dev
bin/check
bin/orb-dev
```

`bin/check` runs Ruby and frontend formatting/linting, TypeScript, Minitest,
Vitest, production assets and eager loading, Brakeman, Ruby and JavaScript
dependency audits, and Playwright. GitHub Actions starts from PostgreSQL and
frozen lockfiles and invokes that same command.

Development and test database names include a stable hash of the worktree
realpath, overridable with `DATABASE_SUFFIX`. Solid Queue's initial Phase 2
process topology uses its Rails-generated queue connection; Phase 4 records the
final same-logical-database topology.

The Amp service invokes `bin/orb-dev`, uses watched built assets under one
portal origin, runs web and worker processes, and gates readiness on `/ready`.
`.agents/setup` remains the complete system/runtime installer and
`.agents/resume` validates installed dependencies before preparing and seeding
the isolated databases.

## Operational foundation

- Production logs are JSON with UTC timestamps, severity, request IDs, and job
  IDs.
- Request IDs propagate into Active Job serialization as correlation IDs.
- `/up` is process liveness; `/ready` checks PostgreSQL and pending migrations;
  `/health` remains the human-readable Inertia state.
- Sensitive parameter names include credentials, cookies, authorization,
  provider bodies, and payloads.
- The root React tree has a safe render error boundary.
- `.env.example` contains names and safe values only; `bin/doctor` never prints
  configured values.

Authentication seed users and the development agent-login route correctly remain
deferred until Phase 3 sessions exist.

## Current-toolchain adjustment

TypeScript 7.0 has no programmatic compiler API, while `typescript-eslint`
requires one. Following Microsoft's TypeScript 7 side-by-side guidance, the
repository pins `@typescript/typescript6` 6.0.2 as the `typescript` API package
for ESLint and pins TypeScript 7.0.2 as `@typescript/native`; `pnpm exec tsc`
continues to run the TypeScript 7 compiler. This retains the Phase 1 compiler
selection without disabling frontend linting.

## Verification

The implementation was verified with:

```text
.agents/setup
bin/setup
bin/check
amp orb services ensure --json
```

The Amp service reported `already-running`, listening, and HTTP 200 readiness
for `/ready`. Detailed check counts are retained in the implementation thread
and final baseline report because later phases expand the same canonical suite.
