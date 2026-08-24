# Baseline Starter-Kit Implementation Plan

Status: Phases 1–5 implemented; Phases 6–7 authorized and in progress

Last updated: 2026-08-24

## Outcome

Produce a reviewed `0.1` baseline that can generate or configure a clean
`minimal`, `personal`, or `internal` Rails application, run deterministically in
an Amp Orb, and deploy the same image to an owned VM or PaaS.

This plan deliberately separates framework preservation, behavior additions, and
validation. Each phase must leave a reviewable, passing repository.

## Phase 0 — Documentation and decision freeze

### Deliverables

- Vision, product envelope, principles, and decision register
- Existing-starter, Canopy, `build-new`, Event Horizon, and internal-tools
  evidence
- Baseline architecture, auth, integration, feature, deployment, and Amp plans
- Starter, Event Horizon, and LX roadmaps
- Prioritized open questions
- Private GitHub repository and documentation-only commit

### Exit criteria

- Robert reviews the documents.
- The foundational and cross-cutting implementation defaults in
  `open-questions.md` are accepted.
- Robert explicitly authorizes implementation.

## Phase 1 — Runnable Rails/Inertia foundation

Status: implemented on 2026-08-24. See the
[Phase 1 implementation record](implementation/phase-1.md).

### Work

1. Pin supported Ruby, Rails, Node, and pnpm versions from current authoritative
   sources.
2. Generate the smallest Rails application with PostgreSQL.
3. Install Inertia Rails, React 19, TypeScript, and Vite without production SSR.
4. Establish one `app/frontend` root and path aliases.
5. Install Tailwind CSS 4 and only the accepted restrained shadcn/ui component
   set; do not add generic data-table/form/validation abstractions.
6. Add root layout, responsive shell, dark mode, 404, error, empty, loading, and
   health states.
7. Establish Active Record constraints and migration conventions.
8. Use Inertia forms with Rails validation errors and explicit page-local
   TypeScript prop interfaces without initial Ruby-to-TypeScript generation.

### Verification

- Fresh database setup and migrations
- Inertia navigation and form round trip
- TypeScript and Ruby tests
- Production Rails/assets build
- Browser smoke at phone, tablet, and desktop sizes
- No Node SSR process in production image

### Exit criteria

- The application is usable as an unauthenticated minimal profile.
- No provider-specific code or configuration exists.

## Phase 2 — Deterministic developer and agent workflow

Status: implemented on 2026-08-24. See the
[Phase 2 implementation record](implementation/phase-2.md).

### Work

1. Add locked Bundler/pnpm installation and standard scripts: `bin/setup`,
   `bin/dev`, and `bin/check`.
2. Add `Procfile.dev` with Rails, Vite, and worker roles, run through Foreman by
   `bin/dev`; do not retain aube.
3. Add Minitest, Vitest/React Testing Library, and Playwright harnesses.
4. Add RuboCop, Brakeman, dependency auditing, lint, format, typecheck, and
   production build checks.
5. Add CI from an empty PostgreSQL environment.
6. Add per-worktree database naming.
7. Add `.agents/setup`, `.agents/resume`, `.amp/services.yaml`, and
   `bin/orb-dev`.
8. Add deterministic seed data and development-only agent login infrastructure
   once sessions exist; until then, verify public flows.
9. Add structured JSON logs, request/job correlation IDs, redaction,
   health/readiness, container log-rotation guidance, and the `Rails.error`
   reporting boundary.
10. Add `.env.example`, ignored `.env.local`, development/test-only dotenv, and
    `bin/doctor` that reports missing key names without values.

### Verification

- Fresh-clone setup in an Amp Orb
- Orb pause/resume recovery without full reinstall
- Portal health and browser smoke
- `bin/check` on clean repository
- CI and OCI image build

### Exit criteria

- A future agent needs no undocumented setup step.
- The canonical verification command is truthful and green.

## Phase 3 — First-party authentication and closed access

Status: implemented on 2026-08-24. See the
[Phase 3 implementation record](implementation/phase-3.md).

### Work

1. Apply Rails-generated authentication and inspect all generated behavior.
2. Implement app-owned users, sessions, identities, and access grants with
   database constraints.
3. Implement password login with 24-hour, single-use, rotate-on-resend email
   invitations that atomically create the user and claim the grant.
4. Implement interactive bootstrap of exactly one owner without a lasting
   backdoor, plus explicit ownership transfer and last-owner protection.
5. Add access administration UI and grant/revoke commands.
6. Revoke sessions immediately when a user/grant is disabled.
7. Add Google Workspace identity adapter using stable provider subject and
   domain plus explicit-grant checks.
8. Add login/grant/revocation audit events.
9. Add development-only normal/owner/second-user agent login that creates real
   sessions and is 404 in production.

### Required negative tests

- Unknown password user cannot enroll.
- Granted email cannot be stolen by an unauthenticated password-set request.
- Unauthorized Google user creates no local user/session.
- Wrong Workspace domain is rejected.
- Revocation invalidates existing sessions.
- Non-owner cannot manage access.
- External return URL is rejected.
- Development agent login is unavailable in production.

### Exit criteria

- Password-only, Google-only, and combined installed configurations work.
- Public signup remains impossible by default.

## Phase 4 — Rails-native operational capabilities

Status: implemented on 2026-08-24. See the
[Phase 4 implementation record](implementation/phase-4.md).

### Work

1. Configure Solid Queue in the same logical PostgreSQL database with its own
   tables and pool; document the measured-evidence gate for a later split.
2. Add representative idempotent job, worker health checks, and categorized
   retry/discard conventions without blanket retries.
3. Configure Active Storage for local disk and S3-compatible services; keep
   MinIO an optional Compose/CI compatibility profile.
4. Configure Action Mailer with Mailpit development capture, the test adapter,
   and portable SMTP production boundary including Google Workspace relay.
5. Build one production OCI image with web, worker, and release commands.
6. Add Compose local/owned-VM topology and one-shot `bin/rails db:prepare`
   release role; use corresponding Render pre-deploy and Fly release commands
   rather than migrating on process startup.
7. Add backup, restore, retention, and restore-drill scripts/docs.
8. Add startup configuration validation without secret disclosure and recipe
   documentation for secret ownership, scopes, rotation, verification, and
   rollback.

### Verification

- Job survives/retries a worker restart as designed.
- Upload, download, authorization, and deletion work locally and against a test
  S3-compatible service if installed.
- Email preview/capture works without an external provider.
- Image starts web and worker roles independently.
- Database and uploads restore into a disposable environment.

### Exit criteria

- A personal app can run on one VM without hosted application providers.
- The same image is ready for PaaS recipes.

## Phase 5 — Profiles and additive recipe mechanism

Status: implemented on 2026-08-24. See the
[Phase 5 implementation record](implementation/phase-5.md).

### Work

1. Keep the source repository as a runnable minimal reference application.
2. Add `starter/` as the non-runtime profile/capability/recipe source and
   `bin/new` as the clean destination generator.
3. Exclude starter-only research/catalog files and unselected provider code from
   generated apps.
4. Define capability dependencies and explicit profile expansion.
5. Add `.starter.yml` receipt.
6. Generate and verify `minimal`, `personal`, and `internal` fixtures.
7. Support non-interactive flags for Amp.
8. Report exactly which files/configuration a recipe changes.
9. Fail unsupported combinations before partial generation where possible.

### Verification

- Generate each profile from scratch in CI.
- Run that generated app's complete checks and production build.
- Assert personal/minimal output contains no institutional provider code or
  environment keys.
- Apply one additive capability to an existing clean generated app and inspect
  the diff.

### Exit criteria

- Profiles reduce decisions without becoming runtime modes.
- Generated code is normal, owned, and understandable Rails code.

## Phase 6 — Internal/integrations capability

This phase creates provider-neutral operational support, not provider clients.

### Work

1. Add configured Faraday boundary with timeouts, bounded retry, redaction,
   correlation, and deterministic stubs.
2. Add explicit response parsers returning Ruby `Data` and a safe error
   hierarchy without initial `dry-schema`.
3. Add operations with the accepted actor/kind/status/idempotency/step/progress,
   sanitized request/result, error, and lifecycle fields plus the partial unique
   idempotency constraint.
4. Share sanitized audit events with authentication and access administration.
5. Add Solid Queue claim/stale/retry examples, concurrency limits, and a
   PostgreSQL lease/token-bucket example for strict cross-worker pacing.
6. Add the same-origin JSON polling status endpoint and React progress view with
   two-second active polling, backoff toward ten seconds, hidden-page pause,
   terminal stop, and reload recovery.
7. Add optional operation items/import foundation as separate capabilities if
   the scope stays coherent.
8. Add fixture-provider mode and failure simulations.
9. Add the OpenTelemetry capability for Rails, Active Record, Solid Queue, and
   Faraday with no export unless OTLP is configured.

### Verification vertical slice

Use a local fake provider to prove:

- paginated read and normalized snapshot;
- previewed queued write;
- duplicate submission prevention;
- timeout, 429, invalid response, partial success, and ambiguous write handling;
- actor authorization and structured audit;
- worker interruption and stale-operation behavior;
- progress remains visible after browser reload.

### Exit criteria

- LX can begin without inventing its own HTTP/job/audit/progress foundation.
- No Canvas/Populi/Airtable/Circle/Watermark behavior exists in core output.

## Phase 7 — Deployment recipes and baseline release

### Work

1. Validate local Docker Compose.
2. Deploy and restore-test an exe.dev instance.
3. Add and validate thin Render recipe.
4. Add and validate thin Fly.io recipe.
5. Complete generic VPS, secrets, backups, upgrades, and rollback docs.
6. Add changelog, starter-version policy, recipe compatibility policy, and
   conceptual migration guide from the old starter.
7. Review repository privacy and choose a license before any public release.

### Exit criteria

- One image is proven on exe.dev and at least one work-relevant PaaS.
- A new app can be generated, run in an Orb, checked, deployed, backed up, and
  restored using documented procedures.
- Robert approves the `0.1` baseline for Event Horizon validation.

## Implementation discipline

- Commit coherent phases separately when Robert wants reviewable milestones.
- Verify generated profiles, not only the source blueprint.
- Do not use a validation-app need to bypass profile boundaries.
- Record every friction point before changing the starter.
- Treat production provider writes, deployments, migrations, and cutovers as
  separately approved shared-state actions.
