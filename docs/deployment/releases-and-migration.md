# Releases, recipes, and migration

`VERSION` is the starter release version; `CHANGELOG.md` records user-visible
changes. Generated `.starter.yml` receipts identify the starter version and
selected profile/capabilities. Recipes are supported only when applied from a
starter checkout compatible with the receipt's major version. Additive recipes
report changed files but do not auto-merge app modifications. Review changelog,
recipe diff, migrations, and generated output; commit before applying and test
the resulting application. Breaking receipt/recipe semantics require a major
version, while additions and fixes use minor/patch releases.

## From the Convex/Clerk starter

Create a new Rails application and migrate conceptually: inventory Convex
schemas/functions/jobs/files and Clerk users/sessions/roles; design owned Rails
models and explicit access grants; export only authorized data; transform into
staged imports; reconcile counts, ownership, timestamps, files, and sampled
records; invite users into first-party authentication; shadow-test before
cutover; retain the old app read-only through an agreed rollback window.

There is no automatic Convex data or Clerk identity/session/password migration.
Clerk identifiers may be retained only as audited legacy references. Provider
exports, password portability, consent, retention, and deletion must be checked
for the actual application before any production action.
