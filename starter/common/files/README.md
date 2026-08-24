# Rails App

This is an independent Rails application generated from the provider-independent
Rails application starter kit. Its selected build-time profile and capabilities
are recorded in `.starter.yml`; production does not read that receipt.

## Commands

```sh
bin/setup   # idempotent dependency and database setup
bin/dev     # Rails, Vite, jobs, and development mail
bin/check   # complete deterministic verification
bin/orb-dev # supervised Amp Orb entrypoint
```

Copy `.env.example` to the environment used by the deployment and run
`bin/config-check` before release. See [operations](docs/operations.md) for
image roles, backup, restore, and worker-health commands.

The production image contains prebuilt frontend assets and Ruby application
processes. It does not require a production JavaScript process or a hosted
application service.
