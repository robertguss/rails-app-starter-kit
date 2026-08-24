# Rails App Starter Kit

Provider-independent Rails application starter aimed at small internal tools and
personal or family applications.

The project now contains the reviewed **Phase 1 Rails/Inertia foundation**.
Later phases remain unimplemented and require separate authorization.

## Why this project exists

The existing
[`web-app-starter-kit`](https://github.com/robertguss/web-app-starter-kit)
delivers excellent iteration speed with React, Convex, and Clerk, but its
backend, identity, deployment, setup, and runtime are coupled to hosted
providers. This successor is intended to preserve the fast product-development
experience while making the application, data, identity model, and deployment
topology first-party and portable.

The recommended direction is a Rails modular monolith with Inertia React,
PostgreSQL, and boring infrastructure that can run on an owned Linux VM, Render,
or Fly.io.

## Phase 1 application

The runnable reference application includes Rails 8.1, PostgreSQL, Inertia
Rails, React 19, TypeScript, Vite, Tailwind CSS 4, the restrained shadcn/ui
baseline, responsive light/dark application shell, foundation states, and a
Rails-validated Inertia form round trip. Production server-side rendering is
explicitly disabled.

Runtime and package versions, authoritative sources, architecture notes, and
database conventions are recorded in the
[Phase 1 implementation record](docs/implementation/phase-1.md).

Phase 2 will establish the canonical `bin/setup`, `bin/dev`, and `bin/check`
workflow. Until then, after installing the pinned runtimes and PostgreSQL:

```text
bundle install
pnpm install --frozen-lockfile
bin/rails db:prepare
bin/rails server            # terminal 1
bin/vite dev                # terminal 2
```

## Start here

1. [Documentation index](docs/README.md)
2. [Vision and principles](docs/vision-and-principles.md)
3. [Product and deployment envelope](docs/product-envelope.md)
4. [Decision register](docs/decision-register.md)
5. [Baseline implementation plan](docs/implementation-plan.md)
6. [Combined roadmap](docs/roadmap.md)
7. [Open questions](docs/open-questions.md)

## Validation applications

The starter will be validated by rebuilding two real applications after a
reviewed baseline exists:

- **Event Horizon**, the reading-comprehension game for James, validates the
  personal/family profile, rich touch-first React interaction, media, and PWA
  behavior.
- **LX Internal Tools**, an operational application using Canvas, Populi,
  Airtable, Watermark, and Circle, validates the internal profile, Google
  Workspace authentication, integrations, durable jobs, imports, progress,
  idempotency, and auditability.

These applications are proving grounds, not sources from which every feature
will be copied into the starter.

## Status

- Documentation baseline: foundational and cross-cutting implementation defaults
  accepted
- Application implementation: Phase 1 runnable Rails/Inertia foundation
- Implementation authorization: Phase 1 granted; Phase 2 and later not granted
- GitHub repository: private repository created at
  <https://github.com/robertguss/rails-app-starter-kit>

## License

No license has been selected yet. Keep the repository private until licensing
and public-release intent are explicitly decided.
