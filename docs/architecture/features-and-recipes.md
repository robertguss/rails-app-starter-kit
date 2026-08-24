# Features, Profiles, and Recipes

Status: accepted direction; command syntax is illustrative

Last updated: 2026-08-24

## Selection model

There are three layers:

1. **Foundation**: always present and supported.
2. **Capabilities**: coherent build-time features selected directly or by a
   profile.
3. **Recipes**: provider- or workflow-specific code added explicitly.

Profiles are convenience aliases that expand to an explicit feature list. They
must not create hidden runtime behavior.

## Foundation

- Rails + Inertia React TypeScript + Vite
- PostgreSQL
- Solid Queue, Active Storage, and Action Mailer installed as Rails-native
  facilities without generating user-facing workflows
- Tailwind CSS + restrained shadcn/ui baseline
- Health, error, empty, 404, and responsive shell states
- Secure request/session defaults appropriate to whether auth is installed
- Docker image and local development topology
- Test, lint, format, build, security, and CI commands
- Amp Orb setup/resume/services contract
- Structured JSON production logging, request/job correlation, redaction,
  health/readiness, and container log-rotation guidance

## Initial profiles

### `minimal`

- Foundation
- No authentication unless selected
- No user-facing operation, upload, or email workflow
- Worker process only needs to run when the application enqueues jobs
- No integrations or institutional provider code unless added

### `personal`

- Foundation
- Password authentication
- Closed registration and one owner
- Jobs
- Local file storage
- Email only if required by the selected password enrollment/recovery flow

Optional Google login, PWA, media, and family profiles are selected explicitly.

### `internal`

- Foundation
- Google Workspace authentication
- Closed registration and access administration
- Jobs
- Integration HTTP foundation
- Durable operations, polling progress, and audit events
- File imports/exports
- Active Storage and Action Mailer
- OpenTelemetry capability installed, with export enabled only when an OTLP
  endpoint is configured

The internal profile includes no Canvas, Populi, Airtable, Circle, or Watermark
client. OpenTelemetry is a separate capability included by `internal`; it is
absent from the `minimal` and `personal` profiles unless selected explicitly.

## Source repository and generated applications

The source repository is a runnable minimal reference application plus
build-time tooling:

```text
app/                    # runnable minimal Rails reference application
starter/                # capability/profile/recipe sources
bin/new                 # creates a clean destination application
docs/                   # starter design and maintenance context
```

`bin/new` copies the minimal app, applies the selected profile and recipes,
omits the recipe catalog/design research/unselected providers, writes
`.starter.yml`, and produces a normal independent Rails repository.

Adding a feature later uses a checked-out, versioned copy of this starter:

```text
/path/to/rails-app-starter-kit/bin/starter add canvas --app /path/to/my-app
```

The generated application does not depend on the starter repository or an
online generator at runtime.

## Illustrative commands

Creation:

```text
bin/new james-reading-game \
  --profile personal \
  --auth password \
  --with jobs,storage,pwa

bin/new student-success-tools \
  --profile internal \
  --auth google \
  --with integrations,imports,email
```

Additive recipes:

```text
bin/starter add google-auth
bin/starter add integrations
bin/starter add csv-imports
bin/starter add canvas
```

The generator must produce reviewable ordinary files and work
non-interactively for Amp.

## Receipt

Generated apps should retain a documentation receipt:

```yaml
# .starter.yml
starter_version: 0.1.0
profile: personal
features:
  - password-auth
  - jobs
  - storage
recipes: []
```

The receipt supports humans, AI context, and relevant upgrade notes. It is not
read by the production application as a feature registry.

## Environment variables

Environment variables configure installed behavior:

```dotenv
AUTH_METHODS=password
AUTH_SELF_REGISTRATION=false
STORAGE_SERVICE=local
```

An app with a Canvas recipe may define `CANVAS_BASE_URL` and
`CANVAS_ACCESS_TOKEN`; an app without Canvas has no Canvas configuration,
dependency, migration, or code.

## Adding and removing

Recipes should be additive and preferably idempotent when safely possible. They
should print changed files and required configuration.

Do not promise automatic uninstall. Once business code references a generated
integration, a tool cannot reliably determine everything that is safe to
delete. Review the recipe diff and use Git to revert a just-added recipe.

## Testing the matrix

Do not claim support for every combination of dozens of toggles. CI should
generate and validate:

- one `minimal` application;
- one `personal` application;
- one `internal` application;
- each supported recipe against its declared prerequisite profile/capability.

Unsupported combinations should fail generation with a clear explanation.

## Promotion rule

| Discovery | Destination |
|---|---|
| Universal request-security fix | Foundation |
| Needed by most bounded personal apps | Personal profile/capability |
| Durable operation progress | Internal integrations capability |
| Reusable import-preview workflow | Optional recipe |
| Canvas rate-limit behavior | Canvas recipe |
| Event Horizon mission progression | Event Horizon only |

The starter must not become the union of the validation applications.
