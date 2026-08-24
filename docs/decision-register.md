# Decision Register

Last updated: 2026-08-24

This register separates accepted direction from proposed implementation detail.
No decision in this file means the feature has been implemented.

## Accepted direction

| Area | Decision | Rationale |
|---|---|---|
| Repository | Create a clean successor rather than rewrite the existing Convex/Clerk starter in place | The old repository remains useful as a provider-specific edition, while a clean successor avoids carrying coupling and migration debris |
| Framework | Rails modular monolith | Coherent conventions, pleasant Ruby development, excellent AI familiarity, less assembly than Rust or fragmented JavaScript backends |
| UI bridge | Inertia Rails with React 19 and TypeScript | Retains rich React UX without requiring a separate API product or SPA auth architecture |
| Frontend build | Vite | Fast and already familiar from Robert's applications |
| Styling | Tailwind CSS 4, shadcn/ui, Radix primitives, Lucide, CSS-variable theming, dark mode | Preserves current UI speed and flexibility |
| Data | PostgreSQL | Portable across exe.dev, Render, and Fly; supports web/worker processes, snapshots, search, jobs, and future growth |
| Jobs | Solid Queue | Rails-native durable jobs backed by owned database infrastructure |
| Files | Active Storage | Local disk on owned VMs and S3-compatible adapters on PaaS |
| Email | Action Mailer | Framework-owned delivery boundary with optional SMTP/provider adapters |
| Application identity | First-party users, provider identities, and database sessions | Provider login maps into a stable app-owned user rather than becoming the user model |
| Registration | Closed by default with explicit active access grants | Every app needs control over who may join; unauthorized Google users must not create local accounts |
| Login methods | Deployment-selectable password and Google Workspace adapters | Work can be Google-only; personal apps can use password, Google, or both |
| Child identity | Parents authenticate; children are application profiles | Avoids unnecessary child identity-provider accounts and matches Event Horizon |
| Deployment | One OCI image with web, worker, and release commands | Portable and simple across owned VMs and PaaS |
| Hosts | First-class exe.dev, Render, and Fly.io recipes | Matches personal and work deployment needs without dominating architecture |
| Amp | First-class `.agents/setup`, `.agents/resume`, `.amp/services.yaml`, and deterministic agent login | Future sessions and orbs must run and test the app without bespoke recovery work |
| Integrations | Standardize HTTP safety, durable operations, audit, progress, and testing; keep provider behavior app-local | Real repositories repeat operational concerns, not business APIs |
| Feature selection | Build-time profiles and additive generators/recipes; environment variables only configure installed code | Personal apps must contain no dormant institutional integrations |
| Validation | Rebuild Event Horizon first, then LX Internal Tools | The apps test complementary personal and internal-tool boundaries |

## Proposed implementation choices

| Area | Proposal | Review gate |
|---|---|---|
| Package management | Bundler for Ruby and pnpm for frontend dependencies, without a workspace unless a real second package appears | Confirm during skeleton spike |
| Ruby tests | Minitest as the Rails default | Confirm preferred style before Phase 1 |
| Frontend tests | Vitest, React Testing Library, and Playwright | Confirm Inertia test harness during skeleton spike |
| HTTP | Faraday with standardized timeout, retry, redaction, and instrumentation middleware | Validate against one fixture provider |
| Response parsing | Small explicit parsers returning Ruby `Data` objects; add dry-schema only if repetition justifies it | Compare ergonomics in integration vertical slice |
| Authorization | Access-granted member and owner/admin by default; app-local operator permissions only when needed | Finalize password enrollment and owner semantics |
| Basic observability | Structured production logs and correlation IDs in every profile | Implement in foundation |
| OpenTelemetry | Selectable capability, enabled by default for the internal profile and configured through OTLP | Validate maintenance cost before making universal |
| Integration state | `operations` and `audit_events` in the internal/integrations capability, not the minimal personal profile | Validate during LX vertical slice |
| Starter receipt | Checked-in `.starter.yml` records profile, feature list, recipes, and starter version | Implement with generator work |
| Search | PostgreSQL full-text search recipe first; pgvector only after demonstrated semantic-search need | Deferred until a validation app requires search |

## Rejected as defaults

| Choice | Reason |
|---|---|
| Convex backend | Excellent DX but makes data/functions/jobs depend on a specific hosted runtime |
| Clerk-owned application identity | Hosted login can remain an adapter, but the app should own users, sessions, and access |
| Laravel/PHP | Coherent framework, but Robert prefers Ruby and Rails offers the same integrated-framework advantage |
| Rust baseline | Efficient binaries and compiler checks are attractive, but selecting and maintaining crates recreates framework assembly and slows product iteration |
| Fastify/OpenAPI split baseline | Strong Canopy architecture, but unnecessary when Inertia and Rails can keep these apps in one monolith; retain as a recipe for a real external API |
| Production SSR | Adds a Node runtime and cross-runtime behavior without evidence that target apps need SEO SSR |
| Devise default | Mature and maintained, but Rails-generated explicit auth is easier to own, inspect, constrain, and guide for bounded apps |
| Better Auth/Auth.js | JavaScript-oriented and would put the auth center outside the selected Rails architecture |
| Generic RBAC/multi-tenancy | Robert intentionally builds one app per team and controls access explicitly |
| Generic integration plugin framework | The real apps repeat HTTP/job/audit mechanics, not a common provider resource model |
| Runtime flags for uninstalled providers | Leaves unused code, dependencies, migrations, configuration, and attack surface in every app |
| Kubernetes/microservices | No product or scale evidence justifies the operational burden |

## Deferred

- Magic-link login
- Passkeys
- Public self-registration
- Billing
- AI adapters
- Webhook infrastructure
- Provider-account management UI and user-owned OAuth connections
- Generic public API and generated client
- SSE/WebSocket progress in place of baseline polling
- SQLite tiny-app profile
- pgvector
- Offline-first synchronization
- Cloud-specific infrastructure as code
