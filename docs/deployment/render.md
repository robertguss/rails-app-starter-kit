# Render

`render.yaml` builds the repository `Dockerfile` for both web and worker. The
web service alone receives traffic, checks `/ready`, and runs `bin/release`
before deployment. `DATABASE_URL` comes from managed PostgreSQL. Secret values
are deliberately `sync: false`: enter them in Render and never commit them. Add
every profile-specific required name from `.env.example`—for example Google
Workspace settings for `internal`—before the pre-deploy configuration check.

Use S3-compatible object storage; Render service filesystems are not shared
durable application storage. Review service/database plans and names before
creating a Blueprint. Schema reference:
<https://render.com/docs/blueprint-spec>. No Render deployment or restore was
attempted without an approved disposable account, target, and credentials.
