# Open Questions

Last updated: 2026-08-24

These questions are deliberately visible so future agents do not silently turn
proposals into facts.

## Blockers before starter implementation

### 1. Source-repository shape

Recommended: make this repository a runnable minimal reference application plus
a non-runtime configurator/recipe catalog that can generate clean destination
apps. Alternatives are a pure Rails application template or a separate CLI.

Decision criteria:

- generated apps contain only selected code;
- the source blueprint and every generated profile can be tested in CI;
- recipes work non-interactively in Amp;
- generated code is ordinary Rails code;
- no remote code execution or always-online generator dependency;
- upgrades can explain relevance through `.starter.yml` without pretending to
  auto-merge application changes.

### 2. Exact supported versions

Confirm current stable Ruby, Rails, Inertia Rails, React, Vite Rails, Tailwind,
and shadcn compatibility at implementation time. Do not assume version numbers
from memory or this document.

### 3. Ruby testing style

The recommendation is Minitest because it is Rails-native and reduces baseline
dependencies. Confirm whether Robert wants Minitest or RSpec before tests
establish repository-wide patterns.

### 4. Password enrollment and recovery

Choose the exact closed-registration flow:

- grant plus emailed single-use invitation/password-set token; or
- owner-created user plus emailed password-set token.

Define token expiry, replay protection, resend, recovery, email change, and
behavior when no transactional email provider is installed.

### 5. Owner/admin semantics

Decide whether the baseline has:

- exactly one owner plus ordinary members;
- multiple access administrators; or
- a simple admin marker.

Avoid turning this into generic RBAC. Define owner transfer and last-owner
protection.

### 6. Starter profile contents

Confirm whether Solid Queue, Active Storage, and Action Mailer remain installed
in the minimal Rails foundation when economically provided by Rails, or are
physically omitted until selected. User-facing operations/imports must remain
optional regardless.

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
