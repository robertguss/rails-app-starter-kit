# Phase 1 Implementation Record

Status: implemented

Implemented: 2026-08-24

## Outcome

Phase 1 turns the design repository into a runnable, unauthenticated Rails
reference application with PostgreSQL and one client-rendered Inertia React
frontend. It includes a responsive shell, dark mode, the accepted restrained
shadcn/ui set, Rails-backed form validation, and explicit empty, loading,
health, 404, and 500 states.

No authentication provider, external integration, profile/generator catalog,
deployment recipe, Solid Queue configuration, production image, or other Phase
2+ functionality was added.

Active Storage and Action Mailer remain loaded as accepted Rails-native
foundation facilities. Because image workflows belong to Phase 4, Phase 1
explicitly disables Active Storage variant processing instead of adding an
otherwise unused image-processing dependency.

## Selected versions and sources

All direct Ruby and JavaScript dependencies are exact in `Gemfile`,
`package.json`, `Gemfile.lock`, and `pnpm-lock.yaml`.

| Layer                             |                                                                                                                                                             Selected version | Authoritative source and decision                                                                                                                                                                                                                                                                               |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Ruby                              |                                                                                                                                                                        4.0.6 | [Ruby downloads](https://www.ruby-lang.org/en/downloads/) identified 4.0.6 as the current stable release. Rails and the complete locked bundle were installed and exercised on it.                                                                                                                              |
| Rails                             |                                                                                                                                                                      8.1.3.1 | [RubyGems](https://rubygems.org/gems/rails/versions/8.1.3.1) identified 8.1.3.1 as the latest stable security release and requires Ruby 3.2 or newer.                                                                                                                                                           |
| Rails runtime support             |                                                                                                                                      pg 1.6.3 / Puma 8.0.2 / Bootsnap 1.25.0 | RubyGems: [`pg`](https://rubygems.org/gems/pg/versions/1.6.3), [`puma`](https://rubygems.org/gems/puma/versions/8.0.2), and [`bootsnap`](https://rubygems.org/gems/bootsnap/versions/1.25.0). These are the exact compatible stable versions used by the generated PostgreSQL application.                      |
| Node.js                           |                                                                                                                                                                      24.19.0 | [Node.js releases](https://nodejs.org/en/about/previous-releases) identified 24.19.0 as Latest LTS. Node 26 was Current rather than LTS, so the starter pins Node 24 for the supported application toolchain.                                                                                                   |
| pnpm                              |                                                                                                                                                                      11.23.0 | The [npm registry](https://www.npmjs.com/package/pnpm/v/11.23.0) identified 11.23.0 as stable. The [pnpm installation guide](https://pnpm.io/installation) listed pnpm 12 as a release candidate and confirms pnpm 11 supports Node 24.                                                                         |
| Inertia Rails                     |                                                                                                                                                                       3.22.0 | [RubyGems](https://rubygems.org/gems/inertia_rails/versions/3.22.0) identified 3.22.0 as current stable.                                                                                                                                                                                                        |
| Inertia React / Vite plugin       |                                                                                                                                                                        3.7.0 | The npm registry entries for [`@inertiajs/react`](https://www.npmjs.com/package/@inertiajs/react/v/3.7.0) and [`@inertiajs/vite`](https://www.npmjs.com/package/@inertiajs/vite/v/3.7.0) identified 3.7.0 as current stable. The React adapter requires React 19; the Vite plugin supports Vite 7 and 8.        |
| React / React DOM                 |                                                                                                                                                                       19.2.8 | npm registry: [`react`](https://www.npmjs.com/package/react/v/19.2.8) and [`react-dom`](https://www.npmjs.com/package/react-dom/v/19.2.8).                                                                                                                                                                      |
| Vite Rails                        |                                                                                                                                                                       3.11.1 | [RubyGems](https://rubygems.org/gems/vite_rails/versions/3.11.1) identified 3.11.1 as current stable and compatible with Rails 8.                                                                                                                                                                               |
| Vite / React plugin / Ruby plugin |                                                                                                                                                        8.2.2 / 6.1.0 / 5.2.2 | npm registry: [`vite`](https://www.npmjs.com/package/vite/v/8.2.2), [`@vitejs/plugin-react`](https://www.npmjs.com/package/@vitejs/plugin-react/v/6.1.0), and [`vite-plugin-ruby`](https://www.npmjs.com/package/vite-plugin-ruby/v/5.2.2). Vite 8 supports Node 24.                                            |
| TypeScript                        |                                                                                                                                                                        7.0.2 | [npm registry](https://www.npmjs.com/package/typescript/v/7.0.2).                                                                                                                                                                                                                                               |
| Type definitions                  |                                                                                                                              React 19.2.18 / React DOM 19.2.4 / Node 24.13.3 | npm registry: [`@types/react`](https://www.npmjs.com/package/@types/react/v/19.2.18), [`@types/react-dom`](https://www.npmjs.com/package/@types/react-dom/v/19.2.4), and [`@types/node`](https://www.npmjs.com/package/@types/node/v/24.13.3).                                                                  |
| Tailwind CSS / Vite plugin        |                                                                                                                                                                        4.3.3 | npm registry: [`tailwindcss`](https://www.npmjs.com/package/tailwindcss/v/4.3.3) and [`@tailwindcss/vite`](https://www.npmjs.com/package/@tailwindcss/vite/v/4.3.3). The implementation follows Tailwind's [official Vite installation](https://tailwindcss.com/docs/installation/using-vite).                  |
| shadcn CLI                        |                                                                                                                                                                       4.19.0 | [npm registry](https://www.npmjs.com/package/shadcn/v/4.19.0). The checked-in source uses the accepted `new-york` style, Neutral base, CSS variables, consolidated Radix primitives, and Lucide configuration documented by [shadcn's `components.json` reference](https://ui.shadcn.com/docs/components-json). |
| shadcn runtime dependencies       | `radix-ui` 1.6.7, `lucide-react` 1.33.0, `class-variance-authority` 0.7.1, `clsx` 2.1.1, `tailwind-merge` 3.6.0, `tw-animate-css` 1.4.0, `sonner` 2.0.8, `next-themes` 0.4.6 | Exact versions resolved from the npm registry by shadcn 4.19.0 and then pinned.                                                                                                                                                                                                                                 |
| Ruby test / browser test          |                                                                                                                           Minitest 6.0.6 / Vitest 4.1.11 / Playwright 1.62.1 | Minitest is locked through Rails; Vitest and Playwright are exact direct development dependencies.                                                                                                                                                                                                              |

PostgreSQL remains the required database service rather than a package shipped
by the repository. Phase 1 was verified locally against PostgreSQL 15.19. Host
and image support decisions belong to later deployment phases.

## Current-framework adjustments

### Inertia 3 Vite plugin

The design expected Inertia React but predated the current Inertia 3 setup.
Inertia 3's official client setup now includes `@inertiajs/vite`. The plugin is
therefore pinned and installed. The entrypoint intentionally supplies an
explicit browser `setup` callback; no SSR entrypoint exists, the Rails adapter
sets `ssr_enabled = false`, and no `ssr` package script or production Node role
exists.

### Current shadcn source shape

Current shadcn New York components import the consolidated `radix-ui` package
instead of separate `@radix-ui/react-*` packages and generate a `next-themes`
dependency for Sonner. This preserves the accepted Radix/Lucide/CSS-variable
boundary with fewer direct package names. Exactly these accepted components are
checked in:

```text
alert, avatar, badge, button, card, checkbox, dialog, dropdown-menu,
input, label, progress, select, separator, sheet, skeleton, sonner,
table, tabs, textarea, tooltip
```

No form, generic data-table, calendar, chart, command palette, editor,
drag/drop, React Hook Form, or Zod application abstraction was added. The shadcn
CLI has its own internal Zod dependency, but Zod is not an application runtime
dependency and no application code imports it.

### TypeScript 7 path configuration

TypeScript 7 removed the legacy `baseUrl` compiler option. The accepted `@/*`
alias remains, but it is expressed directly with `paths` and mirrored in Vite
instead of copying the older shadcn example's `baseUrl` setting.

### React DOM type publication age

`@types/react-dom` 19.2.5 was published less than five hours before dependency
resolution and failed pnpm's active 24-hour minimum-release-age policy. The
starter pins the immediately preceding compatible stable 19.2.4 rather than
checking in a one-package policy bypass. This does not change the React 19.2.8
runtime.

## Application structure

All browser source is under one root:

```text
app/frontend/
  components/       shell, foundation states, and checked-in shadcn UI
  entrypoints/      one client-only application entrypoint
  lib/              shadcn class-name utility
  pages/            explicit Inertia pages and page-local prop interfaces
  styles/           Tailwind 4 and Neutral CSS-variable theme
  types/            shared Inertia page props only
```

Rails controllers own routes, props, validation, redirects, status codes, and
the PostgreSQL health query. The demonstration form uses an `ActiveModel` object
because Phase 1 has no product domain to persist; inventing a sample table
solely for the starter would leave fake domain code in every future app.

## Active Record and migration conventions

The foundation deliberately has no product tables. Future migrations must:

- express required values with `null: false` and intentional defaults;
- use foreign keys for relational ownership;
- pair model uniqueness validation with a unique database index;
- use check constraints for finite statuses, bounded numeric values, and other
  row-local invariants;
- make related writes transactional;
- keep migrations reversible and avoid application model constants in data
  migrations;
- use expand/migrate/contract for non-atomic production changes;
- add large indexes concurrently in a migration with the transaction disabled;
- use normal Rails migrations and run `db:prepare` once in a later release role,
  never automatically in every web or worker process.

Phase 1 used the default Rails schema format. Phase 3 deliberately moved the
primary database to `structure.sql` when the exactly-one-usable-owner invariant
adopted a deferred PostgreSQL constraint trigger that `schema.rb` cannot
represent faithfully. The Solid Queue schema remains a Ruby schema dump.

## Direct Phase 1 verification

Phase 2 will add the canonical `bin/check`. Phase 1 is checked directly with:

```text
bin/rails db:prepare
bin/rails test
pnpm typecheck
pnpm test
pnpm test:browser
RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile
RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 bin/rails runner 'Rails.application.eager_load!'
```

The browser suite covers an Inertia navigation and Rails validation/redirect
round trip, phone/tablet/desktop shell behavior, dark mode, empty/loading/health
states, and the Inertia 404 and 500 responses. The Ruby configuration test
protects the absence of a production SSR entrypoint and script.

The completed 2026-08-24 verification produced:

```text
fresh PostgreSQL database: created and prepared successfully
Minitest: 10 runs, 36 assertions, 0 failures, 0 errors
Vitest: 1 file, 2 tests passed
Playwright: 5 browser tests passed
production Vite build: 2,479 modules transformed
production eager load: ok; Rails 8.1.3.1, Ruby 4.0.6, Inertia Rails 3.22.0,
  SSR false
```
