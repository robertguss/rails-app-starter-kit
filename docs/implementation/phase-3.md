# Phase 3 Implementation Record

Status: implemented

Implemented: 2026-08-24

## Outcome

The source app now owns closed-access users, digest-backed expiring database
sessions, password invitations and recovery, Google identities, grants, exactly
one transferable owner, and sanitized authentication audit events. Browser
tokens are opaque and only their HMAC-SHA-256 digests are persisted.

Ownership has two database layers: a partial unique index prevents two owner
rows, and a deferred PostgreSQL constraint trigger verifies that an application
with users has exactly one active owner with an active access grant. This
adopted PostgreSQL feature moves the primary schema dump to `structure.sql`; the
Solid Queue schema remains a Ruby dump. Model safeguards reject direct demotion,
deactivation, grant revocation, and destruction of the owner.

Password enrollment requires a live 24-hour invitation attached to an active,
unclaimed grant. Recovery is non-enumerating, rotates tokens, changes the
password, revokes prior sessions, and requires a new login. Google callback
fixture coverage validates immutable subject, verified email, Workspace domain,
and active-grant policy; no live OAuth or external email delivery is claimed.

Development seeds provide deterministic owner, member, and second-user records.
The agent login uses ordinary sessions and has an independently testable
production-negative guard. It is available in development and through an
explicit non-production flag used by the browser test server; production always
returns 404 even if that flag is set.

## Commands

`bin/rails access:bootstrap`, `bin/rails access:grant[email]`,
`bin/rails access:revoke[email]`, and `bin/rails access:reset[email]` manage
no-web-setup deployments. Owners use `/settings/access` for normal grant,
revoke, resend, and ownership transfer.

## Verification

Use `bin/check`. Authentication's Rails tests cover token digests, invitation,
recovery, password and Google login denials, revocation, owner authorization and
transfer, return-path sanitization, mail, and the production-negative agent
guard. The Phase 3 gate passed 34 Minitest cases with 148 assertions, three
Vitest cases, eight Playwright cases across phone, tablet, and desktop states,
production asset/eager-load checks, Brakeman with zero warnings, and Ruby/JS
dependency audits with no known vulnerabilities. Google tests use adapter-shaped
fixtures without credentials; no live Google tenant was used.
