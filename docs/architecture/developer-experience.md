# Developer Experience and Amp Orbs

Status: accepted direction; exact scripts are proposed

Last updated: 2026-08-24

## Goal

A human or AI agent should go from a fresh clone to a verifiable application
without rediscovering setup, secrets, process topology, test users, or browser
journeys.

## Canonical commands

Planned interface:

```text
bin/setup       install locked dependencies, prepare databases, seed fixtures
bin/dev         run normal local development processes
bin/check       format check, lint, types, Ruby tests, frontend tests, build,
                security checks, and selected browser smoke tests
bin/orb-dev     bind to $PORT, respect $PUBLIC_URL, and serve the Orb workflow
```

Commands must be non-interactive when requested, fail clearly, and avoid
silently using production credentials.

## Amp files

### `.agents/setup`

Executable and idempotent fresh-orb setup:

- install pinned Ruby and required system packages;
- install Bundler and pnpm dependencies from lockfiles;
- prepare PostgreSQL and deterministic development/test databases;
- run migrations and deterministic seeds;
- install browser dependencies needed by Playwright;
- never write real secrets;
- never leave foreground or unmanaged background services running.

### `.agents/resume`

Fast idempotent wake repair:

- confirm dependencies and generated artifacts are present;
- prepare/migrate development databases when needed;
- avoid a full reinstall on every resume;
- print concise next commands.

### `.amp/services.yaml`

Declare supervised services and readiness:

- Rails web/combined development service exposed through an Amp Portal;
- Solid Queue worker when relevant;
- useful links such as app and health;
- deterministic health check;
- review widget enabled for UI review unless a page requires otherwise.

Generated `.amp/portals/*.json` files must be ignored.

## Browser access and agent authentication

Production authentication often cannot be automated safely in an Orb. Include
a development-only agent login route that:

- is unavailable (404) in production;
- uses deterministic seeded normal, owner/admin, and second-family users;
- creates a normal application session rather than bypassing authorization;
- accepts only validated internal return paths;
- is covered by an environment-negative test.

Provider login itself still needs focused adapter tests and an explicit live
smoke procedure.

## Fixture provider mode

Integration recipes should run without production credentials:

- deterministic sanitized fixtures;
- simulated pagination, throttling, malformed responses, timeout, partial
  success, and duplicate conditions;
- no fallback from missing fixture configuration to a live provider;
- fixture mode clearly visible in development UI/logs.

## Worktrees and databases

Parallel AI work should not share mutable development/test databases. Derive a
safe database suffix from the worktree or explicitly assigned environment and
document how to reset it. Keep this convention simple enough to understand from
`database.yml` and scripts.

## AI guidance

The implemented starter should maintain an `AGENTS.md` covering:

- architecture and ownership boundaries;
- accepted commands;
- authentication and authorization invariants;
- provider-call requirements;
- forbidden shortcuts;
- test expectations;
- deployment/shared-state safety;
- links to concise domain docs.

Avoid enormous duplicated framework tutorials. Prefer local decisions and
executable verification.

## CI

CI should start from an empty environment and run:

- frozen Bundler/pnpm installs;
- database creation and migrations;
- RuboCop and frontend lint/format checks;
- TypeScript checks;
- Minitest and Vitest;
- Brakeman and dependency audits;
- production asset/application build;
- profile/recipe generation tests;
- targeted Playwright smoke flows;
- OCI image build.

Expensive checks may be separated or serialized for constrained environments,
but the canonical `bin/check` must remain honest about what it runs.

## Documentation expectations

Every generated app should include:

- architecture summary;
- setup and deployment instructions;
- environment-variable inventory without values;
- authentication/access model;
- backup and restore runbook;
- provider integration notes when recipes are installed;
- representative browser journeys;
- `.starter.yml` receipt.
