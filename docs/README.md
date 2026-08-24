# Documentation Index

Status: Phases 1–7 implemented; hosted Phase 7 validation remains external

Last updated: 2026-08-24

This index is the durable entry point for future Amp sessions and fresh orbs.

## Purpose and decisions

- [Vision and principles](vision-and-principles.md)
- [Product and deployment envelope](product-envelope.md)
- [Decision register](decision-register.md)
- [Open questions](open-questions.md)

## Architecture

- [Recommended baseline](architecture/baseline.md)
- [Authentication and access](architecture/authentication.md)
- [Third-party integrations](architecture/integrations.md)
- [Features, profiles, and recipes](architecture/features-and-recipes.md)
- [Deployment and operations](architecture/deployment-and-operations.md)
- [Developer experience and Amp Orbs](architecture/developer-experience.md)

## Research and evidence

- [Existing web-app-starter-kit audit](research/existing-starter-kit.md)
- [Stack evaluation for AI-written applications](research/stack-evaluation.md)
- [Canopy lessons](research/canopy-lessons.md)
- [`buildermethods/build-new` review](research/build-new.md)
- [Internal-tools integration review](research/internal-tools.md)
- [Event Horizon product record](research/james-event-horizon.md)

## Execution

- [Baseline implementation plan](implementation-plan.md)
- [Phase 1 implementation record](implementation/phase-1.md)
- [Phase 2 implementation record](implementation/phase-2.md)
- [Phase 3 implementation record](implementation/phase-3.md)
- [Phase 4 implementation record](implementation/phase-4.md)
- [Phase 5 implementation record](implementation/phase-5.md)
- [Phase 6 implementation record](implementation/phase-6.md)
- [Phase 7 implementation record](implementation/phase-7.md)
- [Operations runbook](operations.md)
- [Deployment runbooks](deployment/operations.md)
- [Combined roadmap](roadmap.md)
- [Event Horizon rebuild roadmap](roadmaps/james-reading-app.md)
- [LX Internal Tools rebuild roadmap](roadmaps/lx-internal-tools.md)

## Status language

- **Accepted direction**: Robert agreed with the direction during design. Exact
  implementation may still require normal engineering decisions.
- **Accepted implementation default**: use this choice when its phase begins
  unless measured implementation evidence justifies revisiting it.
- **Proposed**: recommended but should be reviewed before implementation.
- **Deferred**: intentionally excluded until evidence requires it.
- **Rejected as default**: may still be appropriate for a particular app, but
  not for the starter baseline.

## Source conversations and repositories

- Starter-kit design thread:
  [`T-01a02fe7-70cd-768a-87aa-3eefa8e4132c`](https://ampcode.com/threads/T-01a02fe7-70cd-768a-87aa-3eefa8e4132c)
- Event Horizon thread:
  [`T-01a02c82-1983-721a-8fd8-87caa8da3839`](https://ampcode.com/threads/T-01a02c82-1983-721a-8fd8-87caa8da3839)
- Existing starter:
  [`robertguss/web-app-starter-kit`](https://github.com/robertguss/web-app-starter-kit)
- Rails reference researched:
  [`buildermethods/build-new`](https://github.com/buildermethods/build-new)
- Internal-tool evidence:
  [`robertguss/LX-Internal-Tools-Platform`](https://github.com/robertguss/LX-Internal-Tools-Platform)
  and
  [`robertguss/wts-student-success-internal-tools`](https://github.com/robertguss/wts-student-success-internal-tools)

These documents synthesize the sources; they do not copy implementation from
`buildermethods/build-new`, whose repository did not expose a recognized license
when reviewed.
