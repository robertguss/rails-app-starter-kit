# Stack Evaluation for AI-Written Applications

Status: decision rationale

Last updated: 2026-08-24

## Changed decision context

Before AI wrote essentially all implementation code, Robert naturally chose
languages and frameworks he already knew because he had to type and maintain
the code directly. With Amp and other AI tools writing nearly all code, almost
any language becomes superficially available. That freedom creates stack
paralysis unless the selection criteria change.

The correct question is not "what language can AI generate?" It is:

> Which stack gives AI and Robert the clearest conventions, fastest executable
> feedback, smallest architectural decision surface, safest defaults, and most
> understandable operations over years of maintenance?

## Criteria

1. **Coherent conventions**: common tasks have one obvious framework path.
2. **AI representation**: training data, documentation, and examples are broad
   and mature.
3. **Executable feedback**: tests, types, schema constraints, linters, and
   security tools catch incorrect generated code.
4. **Low composition burden**: the project does not need to invent its own
   framework from packages/crates.
5. **Product speed**: forms, auth, jobs, files, email, and migrations are quick
   to add correctly.
6. **Operational portability**: runs on an owned VM and common PaaS without a
   provider runtime.
7. **Local comprehensibility**: when AI fails, Robert can read the code and
   architecture without decoding excessive magic.
8. **Pleasant ownership**: language/framework should remain enjoyable enough
   for Robert to review and reason about.

## Options considered

### Existing TypeScript + Convex + Clerk starter

Strengths:

- Proven exceptional build speed for Robert's internal tools
- Excellent React/TypeScript UI experience
- Convex realtime/jobs/functions and Clerk auth remove setup friction
- Strong current test and setup conventions

Why not the provider-independent successor default:

- Backend functions, data, jobs, auth bridge, and deployment are coupled to
  hosted products.
- Self-hosting requires replacing the center, not swapping one adapter.
- The existing repository should remain available when provider convenience is
  the right tradeoff.

### Custom TypeScript modular monolith

Candidate: React/Vite, Fastify, OpenAPI, PostgreSQL/Drizzle, pg-boss, S3, and
provider adapters, as proven in Canopy.

Strengths:

- One language across browser/server
- Excellent TypeScript and contract feedback
- Explicit boundaries and portable infrastructure
- Strong fit for public APIs and multiple clients

Tradeoffs:

- Requires choosing and integrating routing, schemas, ORM, migrations, jobs,
  auth, mail, files, security, and deployment conventions.
- OpenAPI/generated-client work is overhead for Inertia-shaped bounded apps.
- Fragmentation increases the number of architectural choices AI can make
  inconsistently.

Keep this architecture for applications that truly need a separately consumed
API or where TypeScript end to end is itself a requirement.

### Laravel + Inertia React

Strengths:

- Excellent integrated full-stack framework
- Strong first-party auth/jobs/mail/files/database ecosystem
- Inertia is a natural fit
- Productive deployment and testing story

Tradeoff decisive for this project:

- Robert strongly prefers Ruby to PHP. With Rails offering the same broad
  framework-coherence advantage, choosing the less pleasant language has no
  compensating requirement.

### Rails + Inertia React

Strengths:

- Coherent conventions for HTTP, database, migrations, sessions, jobs, files,
  mail, security, and tests
- Ruby is pleasant for Robert to inspect and reason about
- Very broad AI and documentation corpus
- Rails 8's generated authentication and Solid infrastructure support owned
  boundaries
- Inertia keeps React/TypeScript and shadcn without a separate API architecture
- Straightforward Docker/VM/PaaS deployment
- Mature static security and dependency tooling

Tradeoffs:

- Ruby uses more memory than a small Rust binary.
- Type feedback is weaker than end-to-end TypeScript or Rust, so database
  constraints, runtime validation, tests, and linting matter more.
- Inertia/Rails/Vite integration must be pinned and tested as a coherent set.
- Owning auth and PostgreSQL creates real security and operational work.

Conclusion: best current default for the declared envelope.

### Rust web stack

Strengths:

- Small memory footprint
- Excellent compiler guarantees
- Efficient, potentially single-binary backend deployment
- Strong correctness for concurrency and data types

Why not the starter default:

- A full-stack product still needs React/browser tooling or a different UI
  compromise.
- Choosing among web, ORM, migrations, auth, jobs, email, storage, templates,
  and testing crates recreates framework construction.
- Compiler errors help implementation correctness but do not choose product
  architecture or prevent incorrect business behavior.
- AI can generate Rust, but iteration and debugging cost is higher when
  framework-level examples and conventions are less unified.

Rust remains appropriate for a measured hot path, systems service, or product
whose resource constraints justify it—not as a speculative optimization for
small internal/family apps.

## Resulting AI strategy

Use Rails conventions as the default decision engine, then reinforce them with:

- PostgreSQL constraints;
- explicit external-boundary parsing;
- Minitest, Vitest, and Playwright;
- RuboCop, Brakeman, and dependency audits;
- deterministic Amp setup and browser fixtures;
- `AGENTS.md` architecture and forbidden-pattern guidance;
- one canonical verification command;
- real validation applications.

AI capability broadens implementation options, but it does not make ecosystem
coherence, operations, security, or long-term ownership irrelevant. It makes
those boundaries more important because generated code can otherwise drift
quickly across plausible patterns.
