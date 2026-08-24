# Phase 7 Implementation Record

Status: locally implemented; hosted validation pending

Implemented: 2026-08-24

## Outcome

Added replaceable Render and Fly host descriptors, Compose-based exe.dev and
generic VPS guidance, operational and migration/release policy, and
deterministic static role validation. All recipes preserve one image with web,
worker, and one-shot release roles; host configuration introduces no application
layer.

`VERSION` and `CHANGELOG.md` establish the private `0.1.0` baseline. Generated
receipts retain that starter version, additive recipes are major-version scoped,
and the migration guide deliberately describes a staged conceptual migration
rather than pretending Convex data or Clerk credentials can be translated
automatically.

## Local validation evidence

- `script/validate-deployment` parsed Render and Compose YAML and asserted one
  Dockerfile, web/worker roles, release commands, readiness, and web-only public
  routing in the Compose, Render, and Fly descriptors.
- Podman built the production Dockerfile. The final image ran as UID 1000,
  contained compiled Vite assets, and contained no `node`, `npm`, `pnpm`, or
  `/rails/node_modules`.
- The explicit Compose core (`postgres`, `release`, `web`, `worker`) ran from
  the final image: release exited 0; PostgreSQL, web, and worker reached
  healthy; `/ready` returned database/migrations/queue `ready`; and
  `bin/worker-health` reported a live Solid Queue process. PostgreSQL had no
  published host port.
- A disposable database and Active Storage volume were seeded with one stored
  object, captured by `bin/backup`, checksum-verified, restored to a disposable
  database/path, and checked through Rails. The restored blob row and stored
  object were readable, and the drill removed its target afterward.

The orb has Podman 4.3 plus the older `podman-compose` adapter rather than
Docker Compose. Core services were selected explicitly because that adapter does
not reliably implement modern Compose profiles; the checked-in profile semantics
remain standard Compose and the core topology completed successfully.

## External gates

Hosted exe.dev, Render, and Fly deployment/restore validation remains blocked by
the absence of explicitly approved disposable targets and credentials, and is
not claimed. No production provider, deployment, or data write occurred. License
selection, public-release approval, and repository visibility also remain
unchanged.
