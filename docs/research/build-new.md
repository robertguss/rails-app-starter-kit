# Review of `buildermethods/build-new`

Status: researched as design evidence

Repository: <https://github.com/buildermethods/build-new>

Last updated: 2026-08-24

## Why it was inspected

`build-new` is a recent opinionated Rails application foundation using many of
the same broad choices under consideration. It helps validate whether Rails,
Inertia, React, PostgreSQL, and first-party authentication form a coherent
modern stack.

## Useful confirmation

The repository demonstrates a practical combination of:

- modern Rails and PostgreSQL;
- Inertia with React and TypeScript;
- database-backed first-party sessions;
- Solid Queue and Rails-native infrastructure;
- explicit controller-to-Inertia props;
- strong agent guidance in `AGENTS.md`;
- strict CI and Brakeman checks;
- worktree-isolated database conventions.

This supports the starter's proposed direction: Rails need not mean abandoning
rich React UI, and first-party sessions can remain understandable application
code.

## Ideas to adapt

- Detailed local architecture instructions for AI agents
- Per-worktree database isolation
- First-party session ownership
- Rails-native jobs and infrastructure
- Explicit page props rather than a hidden generic serialization layer
- Strong security checks and deterministic verification
- Cross-runtime tests if SSR is ever explicitly installed

## Choices not suitable as defaults here

- Mandatory Node SSR
- Rich-text/editor dependencies
- Hatchbox-specific deployment assumptions
- A generic admin boolean as the complete authorization architecture
- Split frontend roots or specialized SEO/PWA machinery without profile need

## Licensing constraint

At the time of research, the repository did not expose a recognized license.
Use architectural ideas only. Do not copy source code, templates, or assets
unless the licensing situation changes and is explicitly reviewed.

## Maturity caveat

`build-new` is useful evidence, not an upstream framework dependency. It is
young, and the successor must independently test its selected Rails/Inertia/Vite
combination, deployment image, auth invariants, and browser behavior.
