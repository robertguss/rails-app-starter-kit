# Vision and Principles

Status: accepted direction

Last updated: 2026-08-24

## Vision

Create the default foundation Robert reaches for when an app idea appears: fast
enough for an AI-assisted experiment, conventional enough for AI and humans to
maintain, and operationally sound enough to keep when the experiment becomes a
real product.

The starter should make the easy path a production-worthy path without turning
every small application into a platform.

## Primary principles

### Own the durable center

The application owns:

- users and stable application identity;
- sessions and access grants;
- PostgreSQL data and migrations;
- business rules and authorization;
- queued operations and audit history;
- deployment artifacts and backup procedures.

External identity, email, object storage, billing, AI, and business APIs map
into application-owned boundaries. They do not become the application's domain
model.

### Optimize for bounded applications

The dominant use cases are:

- a small internal tool for one team or department;
- a personal or family application;
- a product experiment with a narrow initial audience.

Prefer separate applications and deployments over a single internal-tools
platform with generic organizations and RBAC.

### Boring, composable technology

Choose technology with a coherent framework, mature conventions, broad AI
training representation, and a straightforward operational story. Avoid
assembling a custom framework from small libraries merely because each library
is individually attractive.

This is why Rails currently leads Rust and a hand-assembled TypeScript backend:
the integrated conventions matter more than the theoretical freedom to choose
every component.

### AI legibility is a design requirement

AI writes essentially all implementation code in Robert's workflow. Therefore:

- conventions must be explicit and local;
- illegal states should fail through schemas, types, constraints, or tests;
- one command must verify the repository;
- architecture guidance and forbidden patterns must be checked in;
- generated output should be normal framework code, not hidden metaprogramming;
- representative browser journeys must be executable in an Amp Orb;
- provider calls must have deterministic fixture or stub modes.

### Profiles, not a combinatorial framework

Offer a few coherent creation profiles and additive recipes. A profile expands
to an explicit feature list and produces ordinary code. It is not a runtime
mode.

Environment variables configure features that exist. They must not leave
Canvas, Populi, billing, AI, or other unused subsystems dormant inside every
application.

### Security defaults are not optional polish

- Public signup is disabled by default.
- Every authenticated user requires an explicit active access grant.
- Revocation invalidates active sessions.
- State-changing requests use CSRF protection.
- External writes require explicit authorization and idempotency consideration.
- Credentials and sensitive payloads are redacted from logs.
- Dependency, static-security, and browser-level negative tests ship with the
  starter.

### Portability over lowest-effort hosting

The same application image should run on:

- local Docker Compose;
- an owned exe.dev Linux VM;
- Render;
- Fly.io;
- generic container and PostgreSQL infrastructure later.

Deployment recipes remain thin. No hosting vendor owns the application's
identity, data model, or process boundaries.

### Evidence before abstraction

The starter will be validated against Event Horizon and LX Internal Tools.
Promote something back into the starter only when it is:

1. a security or operational default every app should have;
2. required by one of the declared profiles; or
3. genuinely reusable, demonstrated by real implementation evidence.

Provider quirks and product-specific business logic stay local.

## Explicit non-goals for the baseline

- Generic multi-tenancy or organizations
- A general RBAC or policy engine
- Microservices or Kubernetes
- A connector/plugin runtime
- A mandatory public JSON API or generated API client
- Production React SSR
- Billing, AI, vector search, or webhooks in every app
- Multi-account provider credential management
- Fully offline applications
- Automatic extraction of every validation-app feature into the starter
