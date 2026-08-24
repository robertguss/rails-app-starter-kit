# Fly.io

Replace the placeholder app and region, set `DATABASE_URL`, `SECRET_KEY_BASE`,
`APP_HOST`, and S3 credentials with `fly secrets set`, then create at least one
`web` and one `worker` Machine. Both process groups use the same image;
`bin/release` runs once and only web is attached to HTTP with `/ready` checks.
Set every additional required name from the generated profile's `.env.example`,
including Google Workspace settings for `internal`.

Use managed/separately operated PostgreSQL and S3-compatible object storage. A
Fly volume is single-region and attached to one Machine; it is not shared
storage and does not by itself survive every loss scenario. If deliberately
using local files, mount and back up a volume and do not horizontally scale the
writers. References: <https://fly.io/docs/reference/configuration/> and
<https://fly.io/docs/volumes/overview/>. No hosted validation was attempted.
