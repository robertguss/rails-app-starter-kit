# Open Questions

Last updated: 2026-08-24

These questions are deliberately visible so future agents do not silently turn
proposals into facts. Robert accepted the six foundational decisions and all
cross-cutting implementation defaults below on 2026-08-24, then explicitly
authorized Phases 1–7. Phases 1–5 are implemented.

## Resolved foundational decisions

### 1. Source-repository shape

This repository will be a runnable minimal reference application plus a
non-runtime `starter/` configurator/recipe catalog and `bin/new` generator.
Generated destination apps exclude the catalog, design-only documentation, and
unselected providers. Adding a recipe later uses a checked-out version of this
starter; generated apps have no runtime dependency on it.

Decision criteria:

- generated apps contain only selected code;
- the source blueprint and every generated profile can be tested in CI;
- recipes work non-interactively in Amp;
- generated code is ordinary Rails code;
- no remote code execution or always-online generator dependency;
- upgrades can explain relevance through `.starter.yml` without pretending to
  auto-merge application changes.

### 2. Exact supported versions

Resolve and pin current compatible stable Ruby, Rails, Inertia Rails, React,
Vite Rails, Tailwind, and shadcn versions when Phase 1 starts. Do not assume
version numbers from memory or this design snapshot.

### 3. Testing style

Use Minitest for Rails, Vitest with React Testing Library for frontend
components, and Playwright for browser flows.

### 4. Password enrollment and recovery

The owner creates an email grant. A 24-hour, single-use invitation proves inbox
control before one transaction creates the user, claims the grant, sets the
password, consumes the invitation, and creates a session. Resending rotates the
token; revocation invalidates invitations and sessions. Normal browser
enrollment/recovery requires email. Owner-operated CLI tasks support deliberate
no-email deployments.

### 5. Owner/admin semantics

Use exactly one owner plus ordinary members. Ownership is explicitly
transferable, and the last owner cannot be deleted, revoked, or demoted. Product
permissions remain app-local rather than becoming generic RBAC.

### 6. Starter profile contents

Keep Solid Queue, Active Storage, and Action Mailer installed as Rails-native
foundation facilities. Profiles decide which workflows and deployment roles are
generated/configured. Integrations, operation models, imports, and provider code
remain optional.

## Resolved cross-cutting implementation defaults

### Frontend

- Install only `alert`, `avatar`, `badge`, `button`, `card`, `checkbox`,
  `dialog`, `dropdown-menu`, `input`, `label`, `progress`, `select`,
  `separator`, `sheet`, `skeleton`, `sonner`, `table`, `tabs`, `textarea`, and
  `tooltip` from shadcn initially.
- Do not baseline calendars, charts, command palettes, editors, drag/drop, or a
  generic data-table abstraction.
- Use Inertia forms and Rails validation errors. Add React Hook Form or Zod only
  when a specific interactive form justifies duplicate client validation.
- Keep explicit TypeScript page-prop interfaces beside pages; do not generate
  them from Ruby initially. Protect contracts with controller/request tests,
  TypeScript compilation, and representative browser tests.
- Use Bundler and pnpm directly behind `bin/*`; do not retain aube.
- Run Rails, Vite, and the worker through `Procfile.dev` plus Foreman behind
  `bin/dev`. Amp services invoke the same repository commands.

### Database and jobs

- Keep Solid Queue in the same logical PostgreSQL database initially with its
  own tables and pool. Split only after measured contention/scaling evidence.
- Run `bin/rails db:prepare` once before updated web/worker processes through a
  Compose one-shot release container, Render pre-deploy, or Fly release command.
  Never auto-migrate in every process startup; use expand/migrate/contract for
  non-atomic changes.
- Do not apply blanket retries. Retry categorized transient failures only with
  bounded exponential backoff, jitter, `Retry-After`, and a default maximum of
  five attempts for safe work. Discard permanent auth/request/configuration
  failures. External writes require idempotency or reconciliation; unknown and
  ambiguous failures remain visible rather than being blindly retried.
- Use durable operation state and stale-heartbeat checks for user-visible work.

### Secrets

- Environment variables are canonical for deployment/provider secrets. Rails
  encrypted credentials are reserved for framework material where Rails expects
  them; the same key never has both sources or a fallback precedence.
- Commit safe names/defaults only in `.env.example`, ignore `.env.local`, and
  load dotenv only in development/test.
- Amp fixture mode requires no provider secrets. Orb/workspace secrets are
  injected and never written by `.agents/setup`; `bin/doctor` reports missing
  names but never values.
- Provider recipes document ownership, location, scopes, consumers, rotation,
  overlap, verification, and rollback. Rotation follows risk/provider capability
  rather than a fake universal 90-day rule.

### Email and storage

- Generic Action Mailer SMTP is the portable baseline, including Google
  Workspace relay. Postmark, Resend, SES, and other providers are later recipes.
- Use Mailpit in development and the Action Mailer test adapter in tests.
- Use local Active Storage disk for development and small exe.dev apps, and
  S3-compatible storage for Render/Fly/horizontal scale.
- Do not run MinIO everywhere. Keep it as an optional Compose/CI compatibility
  profile; normal tests use disk or SDK stubs as appropriate.

### Observability

- Every profile gets structured JSON production logs, request/job/operation
  correlation IDs, redaction, health/readiness endpoints, and container
  log-rotation guidance.
- `Rails.error` is the app-owned error-reporting boundary; commercial reporters
  are optional adapters.
- OpenTelemetry is a separate capability, included by `internal` and absent from
  `minimal`/`personal`. It instruments Rails, Active Record, Solid Queue, and
  Faraday and exports only when OTLP is configured.
- Start with 30-day log and 7-day trace guidance. Never log provider response
  bodies. Audit, sensitive snapshot, and upload retention remain
  application-specific.

### Integration support

- Use Faraday plus retry middleware and explicit parsers returning Ruby `Data`;
  do not add `dry-schema` initially.
- The internal/integrations capability installs durable `operations` with
  `kind`, `status`, `actor_id`, optional `idempotency_key`, `current_step`,
  current/total progress, sanitized request/result summaries, error
  category/message, and heartbeat/start/finish timestamps. Enforce unique
  `(kind, idempotency_key)` when the key is present.
- Share one sanitized `audit_events` table across auth, access, and external
  commands. Keep `operation_items` an optional batch recipe.
- Poll a small same-origin JSON status endpoint every two seconds while active,
  back off toward ten seconds, pause while hidden, stop when terminal, and
  resume after reload. This does not imply a public API, OpenAPI, or TanStack
  Query.
- Use Solid Queue concurrency limits ordinarily. Use a PostgreSQL lease/token
  bucket for strict shared provider pacing, keep provider quota behavior in
  provider recipes, and never rely on in-memory limits across workers.

## Remaining implementation research, not design blockers

- Phase 1 framework, runtime, gem, and package versions were resolved and pinned
  in [`implementation/phase-1.md`](implementation/phase-1.md).
- Validate the accepted defaults through the planned skeleton and fake-provider
  vertical slices. Change them only when measured implementation evidence
  contradicts the decision.

## Event Horizon questions

1. Must existing family progress and recordings migrate, or can the replacement
   start fresh after preserving authored missions?
2. Audio retention period and parent deletion expectations
3. Parent PIN expiry/re-authentication semantics
4. One family versus multiple-family production requirement
5. Required Week 1/Season 1 parity before switching family usage
6. Private family deployment versus future wider distribution
7. ESV quotation/attribution requirements at the intended distribution scope

## LX questions

1. Which current tools are actively used and deserve rebuild parity?
2. Which staff may execute provider writes versus read reports?
3. Which Convex history must migrate versus be recomputed or archived?
4. Current provider credential scopes and whether narrower credentials can be
   issued
5. Required student/financial data retention and deletion policies
6. Preferred work production target: Render first, then Fly, or both during
   validation
7. Safe non-production provider accounts/data for live integration tests
8. Cutover and rollback window acceptable to operators

## Not blockers for `0.1`

- Public registration
- Magic links or passkeys
- Clerk adapter
- Billing
- AI providers
- Webhooks
- Public API/OpenAPI client
- SSR
- SQLite profile
- Vector search
- Kubernetes/cloud IaC
- Offline-first sync

These should remain deferred until a real application supplies requirements.

## Repository administration

- The private GitHub repository now exists at
  <https://github.com/robertguss/rails-app-starter-kit>.
- Choose a license only before any public release.
- Review child/family details before changing visibility to public.
