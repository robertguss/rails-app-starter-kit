# Authentication and Access

Status: accepted direction; password enrollment mechanics remain open

Last updated: 2026-08-24

## Core rule

Authentication proves identity. An active application-owned access grant
determines whether that identity may enter the app.

No login method may bypass closed registration.

## Owned model

Recommended conceptual tables:

```text
users
  id, email, name, password_digest?, active, owner/admin marker, timestamps

identities
  user_id, provider, provider_subject, provider_email, metadata, timestamps
  unique(provider, provider_subject)

sessions
  user_id, token_digest, user_agent, ip metadata, expires_at, revoked_at

access_grants
  normalized_email, active, granted_by, claimed_by, claimed_at, revoked_by,
  revoked_at, timestamps

audit_events
  actor_id, action, subject, metadata, occurred_at
```

The exact Rails 8 authentication generator schema should be inspected before
implementation and extended rather than replaced unnecessarily.

## Login adapters

Deployment configuration selects from adapters that were installed at project
creation:

```dotenv
AUTH_METHODS=google,password
AUTH_SELF_REGISTRATION=false
GOOGLE_WORKSPACE_DOMAINS=company.com
```

This is boot-time deployment configuration, not an end-user feature flag.

### Google Workspace

Use a conventional OmniAuth/OIDC adapter, expected initially to be
`omniauth-google-oauth2` unless implementation research identifies a better
maintained fit.

The callback must verify or rely on the adapter to verify:

- token signature;
- issuer and audience/client ID;
- expiry;
- OAuth state and OIDC nonce;
- `email_verified`;
- configured hosted-domain (`hd`) claim where a Workspace restriction exists.

Persist Google's immutable `sub` as `provider_subject`. Email is an access and
contact attribute, not the provider identity key.

Login flow:

1. Validate the provider response and deployment domain policy.
2. Resolve an existing `identity` by provider and subject.
3. If none exists, look up an active grant by normalized verified email.
4. Reject without creating a `user` when no active grant exists.
5. Create or bind the user and identity transactionally.
6. Create an application-owned database session.
7. Audit success or denial without logging tokens.

An `hd` check alone is insufficient: the explicit grant list remains required.

### Password

Use Rails-generated authentication and `has_secure_password`, not Devise, as
the baseline. Password authentication is independently enableable for personal
apps.

Closed registration means an arbitrary visitor must not be able to choose a
granted email and set its password. The implementation phase must choose and
test one safe enrollment flow:

- a time-limited, single-use invitation token delivered to the granted email;
  or
- owner-created user plus a time-limited password-setup token.

Bootstrap of the first owner may use a one-time task or deployment-only
environment input. It must not create a permanent production backdoor.

### Magic links and passkeys

Both can reduce password burden, but they introduce email deliverability,
token-replay, device-recovery, or WebAuthn complexity. They are later recipes.
If passwordless becomes a near-term core requirement, reconsider Rodauth rather
than hand-building many advanced auth features.

## Access administration

Every authenticated starter should include:

- an owner/admin access screen at `/settings/access`;
- grant and revoke operations;
- commands such as
  `bin/rails access:grant[user@example.com]` and
  `bin/rails access:revoke[user@example.com]`;
- an auditable bootstrap-owner procedure;
- immediate session invalidation on revocation;
- negative tests proving unauthorized identities cannot create users or
  sessions.

The baseline does not need generic RBAC. The owner/admin distinction exists to
manage access. Applications may add a small local operator permission for
sensitive external commands.

## Family applications

Parents authenticate. Children are app-owned profiles beneath the parent's
family/account and do not need independent Google or password accounts.

Any parent PIN is a convenience boundary unless the product explicitly hardens
it. Store only a password-derived digest combined with a server-side pepper,
rate-limit attempts, and define expiry/re-authentication behavior.

## Session and request security

- Store only a digest of an opaque session token.
- Use `HttpOnly`, `Secure` in production, and appropriate `SameSite` cookies.
- Rotate the session after login and privilege changes.
- Enforce expiry, revocation, and active-user/access-grant checks.
- Protect all state-changing browser requests with Rails CSRF controls.
- Allow only internal validated return paths after login.
- Rate-limit login, password reset, invitation, and parent-PIN attempts.
- Audit grants, revocations, successful logins, denied logins, and session
  destruction.

## Why not the alternatives by default

- **Devise** remains maintained and widely used, but its extension surface and
  indirect behavior are unnecessary for this bounded owned-auth goal.
- **Auth.js and Better Auth** center a JavaScript auth runtime outside Rails.
- **Clerk** may remain an optional identity adapter later, but must map into
  first-party users and sessions.
- **A small owned core** is acceptable only because the scope is deliberately
  constrained to sessions, password login, Google identity, grants, and
  recovery. Do not casually expand it into a general auth product.
