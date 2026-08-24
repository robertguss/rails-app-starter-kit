# Combined Roadmap

Status: proposed

Last updated: 2026-08-24

## Sequence

```text
Documentation and decisions
          |
          v
Rails starter 0.1 foundation, profiles, and integration core
          |
          v
Event Horizon personal-profile validation
          |
          +----> starter corrections / 0.2
          |
          v
LX Internal Tools validation
          |
          +----> recipes / starter corrections / 0.3
          |
          v
Stable default foundation
```

Event Horizon runs first to prove the personal profile remains lean. LX follows
to stress the operational/integration boundary. This ordering prevents internal
tool machinery from silently becoming the definition of every app.

## Milestone A — Captured design baseline

- Private repository
- Complete decision, evidence, architecture, implementation, and validation
  documentation
- Explicit open-question review
- No application code

Gate: Robert approves starting implementation.

## Milestone B — Starter `0.1` foundation

- Rails/Inertia/React/PostgreSQL/shadcn application
- Deterministic setup, checks, CI, and Amp Orb workflow
- First-party sessions, closed registration, password and Google adapters
- Solid Queue, Active Storage, Action Mailer
- One portable production image and Compose
- Minimal/personal/internal profile generation
- HTTP safety, durable operations, audit, idempotency, progress, and fixture
  provider support in the selectable internal/integrations capability
- Basic exe.dev and Render/Fly deployment recipes

Gate: generate the personal profile from scratch and verify/deploy it without
provider-specific application services.

## Milestone C — Event Horizon vertical slice

- Generate from personal profile
- Parent/family/kid identity
- One complete Week 1 mission
- Connection Map, Captain's Log, reward, and parent review
- PWA/iPad flow
- Deploy to a private exe.dev environment

Gate: Robert and James can complete the representative flow on an actual iPad.

## Milestone D — Event Horizon feature rebuild

- Migrate authored Week 1 content and relevant existing progress/assets
- Complete hub, mission, debrief, hangar, and parent views
- Verify audio ownership/retention and cross-family access
- Decide whether/when to migrate Weeks 2–4 and switch stable family usage

Output: starter friction log and a narrowly reviewed `0.2` candidate.

## Milestone E — Starter `0.2` consolidation and internal readiness

- Classify Event Horizon friction and promote only universal, personal-profile,
  or coherent optional recipe improvements.
- Regenerate all profiles to prove Event Horizon changes did not leak family,
  media, or PWA code into unrelated apps.
- Re-run the fake-provider integration vertical slice after starter changes.
- Confirm internal-profile Google Workspace auth, access administration, HTTP
  safety, operations, audit, imports, fixture mode, and observability are ready
  for LX.

Gate: fake-provider vertical slice passes interruption, retry, duplicate, and
partial-failure tests.

## Milestone F — LX Circle vertical slice

- Generate from internal profile
- Google Workspace plus explicit access
- Populi CSV/XLSX preview and repair
- Circle queued enrollment with durable chunks and row outcomes
- Dry-run/fixture mode before live provider commands
- Deploy to a non-production Render environment

Gate: compare outcomes with the current app using sanitized fixtures and an
explicitly approved provider test.

## Milestone G — LX feature rebuild and cutover candidate

- Evalkit read/cache and optional Airtable mirror
- Canvas/Airtable course reset with explicit preview and audit
- Populi reports and exports
- Data migration/recomputation plan
- Shadow/read-only comparison
- Operator acceptance and rollback plan

Output: provider recipes only where the implementation is reusable and a
narrowly reviewed `0.3` starter candidate.

Gate: explicit approval for any production write/cutover.

## Milestone H — Stable starter

- Both validation apps operate successfully
- Profile boundaries remain clean
- Upgrade notes and recipe compatibility are documented
- Backup/restore and deployment evidence exists
- Public/private licensing decision made
- Existing Convex/Clerk starter remains documented as an alternative edition

## Feedback protocol

For every friction item, record:

```text
Observation:
Application and workflow:
Time/repetition cost:
Security or operational impact:
Is it universal, profile-level, recipe-level, or app-specific?
Proposed change:
Evidence after change:
```

Promote only when the category and evidence are clear.

## Release/cutover policy

- Rebuilds start in new repositories and environments.
- Existing applications remain available during validation.
- External mutations begin with fixtures, then dry-run or narrow approved tests.
- Data migration is rehearsed and verified before cutover.
- A production alias/domain is checked against the intended release rather than
  assumed from a successful build.
- Rollback remains available until the replacement has operated successfully
  for an agreed period.
