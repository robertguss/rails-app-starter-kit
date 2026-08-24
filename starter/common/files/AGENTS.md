# Application guidance

This repository is a generated, application-owned Rails codebase. `.starter.yml`
records the starter version, profile, capabilities, and recipes used at
generation time; it is documentation, not a runtime feature registry.

Use boring Rails conventions and keep identity, data, sessions, infrastructure,
and business logic first-party. Add provider-specific behavior only when the
application requires it, and keep it outside general-purpose foundation code.

Standard commands:

```text
bin/setup       # idempotent fresh-clone setup
bin/dev         # local development
bin/check       # complete deterministic verification
bin/orb-dev     # Amp Orb service entrypoint
```

Do not claim checks pass without running them. Do not push, deploy, publish,
change shared infrastructure, or write production data without explicit user
approval for that action.
