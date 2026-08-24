# AGENTS.md

This repository designs and implements Robert Guss's provider-independent Rails
application starter kit.

## Current phase

Phases 1–3 are implemented; Phases 4–7 are authorized. Authentication remains
closed-access: never store raw auth tokens, bypass active grants, weaken the
single-owner database/application safeguards, or expose agent login outside
development and explicit non-production browser-test mode.

Robert accepted the foundational preimplementation decisions and cross-cutting
implementation defaults recorded in `docs/decision-register.md` on 2026-08-24.
The implemented Phase 1 boundary and selected versions are recorded in
`docs/implementation/phase-1.md`.

Start every session by reading:

1. `README.md`
2. `docs/README.md`
3. `docs/decision-register.md`
4. `docs/roadmap.md`
5. `docs/open-questions.md`

Then read the architecture or roadmap documents relevant to the task.

## Product boundaries

- Optimize for independently deployed personal/family apps and small internal
  tools with narrow, explicitly approved audiences.
- Prefer one application per team or bounded problem. Do not introduce generic
  organizations, multi-tenancy, or an RBAC engine without a demonstrated app
  requirement.
- Preserve first-party ownership of application identity, data, sessions,
  infrastructure, and business logic.
- Hosted services may be optional adapters. They must not become required domain
  boundaries.
- Prefer boring Rails conventions and explicit app-local code over a custom
  framework, plugin runtime, or dependency-injection system.
- Provider-specific integrations belong in recipes or applications, never the
  minimal personal profile.
- Do not add public signup. Closed registration and explicit access grants are
  foundational defaults.

## Working principles

- Treat the documents as a decision record, not infallible requirements. When
  evidence from a validation application contradicts a recommendation, record
  the evidence and update the decision deliberately.
- Keep settled decisions, proposals, and open questions visibly distinct.
- Promote a feature into the starter only when it is a universal security or
  operational default, part of a declared profile, or proven genuinely reusable
  by real applications.
- A generated recipe must leave normal application-owned Rails code. Do not
  create a runtime plugin registry.
- Environment variables configure installed features; they do not hide unused
  subsystems.
- Keep the personal profile lean. James's application must not inherit Canvas,
  Populi, Airtable, Circle, or generic enterprise machinery.
- Keep deployment files thin. Application architecture must not be organized
  around exe.dev, Render, Fly.io, or any other host.

## Shared-state safety

Do not push, publish, create deployments, mutate production providers, migrate
production data, or change repository visibility without Robert's explicit
approval for that action.

The Event Horizon research contains family and child-product context. Keep this
repository private until Robert has reviewed what may be published.

## Verification interface

Use these standard commands:

```text
bin/setup       # idempotent fresh-clone setup
bin/dev         # local development
bin/check       # complete deterministic verification
bin/orb-dev     # Amp Orb service entrypoint
```
