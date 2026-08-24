# Phase 5 Implementation Record

Status: implemented

Implemented: 2026-08-24

## Outcome

The repository is now both a directly runnable `minimal` Rails application and a
build-time source for clean `minimal`, `personal`, and `internal` destination
applications. `bin/new` expands a profile into ordinary app-owned files, renames
the Rails application and database namespace, writes `.starter.yml`, and removes
the catalog, design records, generated assets, source database structure, and
starter-maintainer tests from the destination.

Profiles are not runtime modes:

| Profile    | Installed behavior                                                    |
| ---------- | --------------------------------------------------------------------- |
| `minimal`  | Foundation facilities with no authentication or user workflow         |
| `personal` | Closed access, password invitations/recovery, jobs, storage, and mail |
| `internal` | Closed access, Google Workspace identity, jobs, storage, and mail     |

The common closed-access overlay owns users, sessions, identities, access
grants, audit constraints, ownership transfer, access administration, and agent
sessions. Password digest and token tables exist only in the password overlay;
Google dependencies, callback code, configuration names, and identity adapter
exist only in the Google overlay. This is deliberately stricter than retaining
both adapters behind runtime flags and keeps generated attack surface aligned
with the selected profile.

## Commands and receipt

Generation is deterministic and noninteractive:

```text
bin/new APP --profile minimal|personal|internal --path DESTINATION --non-interactive
```

The optional `--auth` argument must agree with the profile, and unsupported
selections fail before destination files survive. The checked-in, profile-
specific Ruby lockfile is copied and checked against direct dependencies rather
than resolved to whatever happens to be current during generation.

Generated applications include a documentation-only receipt:

```yaml
starter_version: 0.1.0
application: example
profile: personal
features:
  - closed-access
  - password-auth
  - jobs
  - storage
  - email
recipes: []
```

`bin/starter add upload-workflow --app DESTINATION` is the first additive
recipe. It validates prerequisites and insertion points before writing, copies
the upload controller and tests, inserts routes and the attachment association,
updates the receipt, prints the exact changed paths, and is idempotent. The tool
does not promise automatic uninstall or create a runtime plugin registry.

## Boundary decision

Rails-native Solid Queue, Active Storage, and Action Mailer remain in every
generated app as foundation facilities, even when there is no user-facing job,
file, or mail workflow. The upload flow that Phase 4 used for operational proof
was moved to the additive recipe so `minimal` and the default profiles do not
silently gain a user-facing upload feature.

The `internal` manifest intentionally did not claim integrations or
OpenTelemetry before Phase 6 implemented them. Phase 6 adds those ordinary files
to the internal build-time expansion; it does not put dormant enterprise
machinery into source, `minimal`, or `personal`.

## Verification contract

`script/verify-profiles` creates all three applications under a fresh temporary
root, runs each output's honest `bin/setup` and complete `bin/check`, and then
applies and integration-tests `upload-workflow`. It also asserts that generated
outputs omit starter internals and that `minimal`/`personal` contain no Google,
institutional-provider, or internal-integration code. CI runs this matrix after
checking the runnable source application.

The generator's focused Minitest coverage additionally proves profile receipts,
selected/absent files, unsupported-combination cleanup, exact recipe change
reporting, and recipe idempotence.
