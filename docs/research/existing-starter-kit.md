# Existing `web-app-starter-kit` Audit

Status: source inspected 2026-08-24

Repository: <https://github.com/robertguss/web-app-starter-kit>

## Current architecture

The current starter is a TanStack Start application with:

- React 19 and TypeScript;
- Vite;
- Tailwind CSS 4 and shadcn/ui;
- TanStack Router/Start;
- Convex functions, database, realtime client, code generation, and test
  runtime;
- Clerk hosted authentication and Clerk-to-Convex JWT integration;
- Vitest, ESLint, Prettier, Husky, and CI;
- aube (`aubr`/`aubx`) as the documented package/task interface.

The current Convex application schema is intentionally minimal/empty, so most
of the value is setup, integration wiring, UI foundation, conventions, and
documentation rather than a domain model that must be migrated.

## Where provider coupling exists

Coupling is structural rather than one replaceable adapter:

- [`app/routes/__root.tsx`](https://github.com/robertguss/web-app-starter-kit/blob/main/app/routes/__root.tsx)
  wraps the application in Clerk and Convex providers.
- [`app/ConvexClientProvider.tsx`](https://github.com/robertguss/web-app-starter-kit/blob/main/app/ConvexClientProvider.tsx)
  creates the Convex client and bridges Clerk auth.
- [`app/start.ts`](https://github.com/robertguss/web-app-starter-kit/blob/main/app/start.ts)
  installs Clerk request middleware alongside CSRF handling.
- The authenticated route layout uses Clerk server auth and redirect behavior.
- [`convex/auth.config.ts`](https://github.com/robertguss/web-app-starter-kit/blob/main/convex/auth.config.ts)
  validates the Clerk issuer and `convex` JWT audience.
- [`convex/auth.ts`](https://github.com/robertguss/web-app-starter-kit/blob/main/convex/auth.ts)
  exposes Clerk identity through Convex.
- `setup.sh`, `scripts/setup-clerk-auth.sh`, `.env.example`, README, CI codegen,
  tests, MCP configuration, and extensive docs all assume Convex and Clerk.
- Backend functions, jobs, persistence, and deployment depend on Convex Cloud.

This means replacing only a provider component would not produce portability;
the successor needs a clean architecture.

## Retain as principles or patterns

- React, TypeScript, Vite, Tailwind, and shadcn development speed
- CSS-variable theming and dark mode
- Strict type, lint, format, test, and dependency checks
- A one-command setup/check intent
- Safe internal redirects
- CSRF middleware
- Root 404 and health endpoints
- Clear authenticated-route boundary
- Test helpers and deterministic setup mindset
- Documentation that explains auth and backend flows to AI agents
- Small-team-friendly UI shell and components

These should be reimplemented using the successor's Rails boundaries rather
than copied mechanically.

## Replace

- Convex schema, functions, realtime runtime, scheduler, storage, generated
  client, and cloud deployment
- Clerk as the owner of application sessions and user lifecycle
- TanStack Start server/router layer
- provider-specific setup scripts and environment requirements
- Convex-specific testing and codegen in CI
- hosted-provider assumptions in onboarding and deployment docs

## Generalize

- Authentication becomes first-party users/sessions/access plus optional login
  adapters.
- Backend setup becomes PostgreSQL/Rails setup.
- Realtime progress becomes durable operations plus polling by default.
- Storage becomes Active Storage with local and S3-compatible services.
- Deployment becomes one image with exe.dev, Render, and Fly recipes.
- Provider setup becomes recipe-specific and absent from apps that do not
  install the provider.

## Agent/Orb gap

The current repository has many checked-in agent skills but does not ship the
target runtime contract:

- `.agents/setup`
- `.agents/resume`
- `.amp/services.yaml`

The successor should make those first-class and tested.

## Supersession strategy

Do not turn the existing repository into Rails in place. Preserve it as the
Convex/Clerk edition for existing projects. Create a clean Rails successor, then
publish a conceptual migration guide after Event Horizon and LX provide real
migration evidence.

The migration guide should map:

- Convex tables/functions to Active Record/controllers/jobs;
- Clerk subjects to app users/provider identities;
- Convex scheduled actions to Solid Queue;
- Convex storage to Active Storage;
- reactive subscriptions to Inertia reload/polling or an optional streaming
  recipe;
- environment/deployment responsibilities to the selected host profile.
