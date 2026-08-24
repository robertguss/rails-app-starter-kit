# Open Questions

Last updated: 2026-08-24

These questions are deliberately visible so future agents do not silently turn
proposals into facts. Robert accepted all six foundational decisions below on
2026-08-24. No unresolved design blocker remains, but Phase 1 implementation
still requires separate explicit authorization.

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
foundation facilities. Profiles decide which workflows and deployment roles
are generated/configured. Integrations, operation models, imports, and provider
code remain optional.

## Decisions needed during baseline implementation

### Frontend

- Exact restrained shadcn component list
- Whether any page-prop type generation is worth its complexity
- Whether pnpm remains the frontend manager or aube is retained as a task layer
- Development process supervisor for Rails + Vite + worker outside Amp

### Database and jobs

- Solid Queue tables in the primary application database versus a separate
  queue database on the same PostgreSQL server
- Migration/release behavior when web and worker deploy separately
- Default job retry/discard conventions and stale-job visibility

### Secrets

- Canonical precedence between environment variables and Rails encrypted
  credentials
- Local secret workflow for agents without allowing secrets into commits/logs
- Default production secret rotation documentation

### Email and storage

- Portable SMTP as only baseline delivery adapter versus one recommended
  transactional provider recipe
- Local email capture tool
- S3-compatible test service in Compose versus stubs in normal development

### Observability

- OpenTelemetry universal, internal-profile default, or separate capability
- Default error reporter integration point
- Metrics/logging gems and data-retention defaults

### Integration support

- Faraday confirmation after a Ruby implementation spike
- Plain parsers/Data objects versus dry-schema/dry-validation
- Exact `operations` schema and whether `audit_events` is shared with auth
- Polling interval/backoff and Inertia partial-reload versus a small JSON status
  endpoint
- Shared rate limiting across multiple workers when a provider has account-wide
  quotas

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
