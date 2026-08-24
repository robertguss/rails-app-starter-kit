# Rails App Starter Kit

Provider-independent Rails application starter aimed at small internal tools and
personal or family applications.

The project contains a runnable minimal Rails/Inertia reference app,
deterministic developer/CI/Amp Orb workflow, Rails-native jobs/files/mail,
portable image and recovery tooling, and build-time profiles for first-party
closed-access authentication. Authorized implementation of the remaining
baseline phases is in progress.

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

After installing the pinned runtimes and PostgreSQL:

```text
bin/setup
bin/dev
bin/check
```

Generate an independent application without the starter catalog or unselected
capabilities:

```text
bin/new family-app --profile personal --path ../family-app --non-interactive
bin/new staff-tool --profile internal --path ../staff-tool --non-interactive
```

`minimal` has no authentication, `personal` installs password closed access, and
`internal` installs Google Workspace closed access. Each output records its
expanded build-time selection in `.starter.yml`; production code never reads
that receipt as a feature registry. A versioned starter checkout can apply an
additive recipe and report every changed file:

```text
bin/starter add upload-workflow --app ../family-app
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
- Application implementation: Phases 1–5 complete; Phases 6–7 in progress
- Implementation authorization: Phases 1–7 granted
- GitHub repository: private repository created at
  <https://github.com/robertguss/rails-app-starter-kit>

## License

No license has been selected yet. Keep the repository private until licensing
and public-release intent are explicitly decided.
