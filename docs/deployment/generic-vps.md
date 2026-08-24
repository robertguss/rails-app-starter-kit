# Generic VPS

Install Docker/Compose on a patched VM and run `compose.yaml` from a pinned
revision. Only `${PORT}:3000` is published; firewall it to the local reverse
proxy when possible. Terminate HTTPS with a supervised Caddy, nginx, or host
proxy, forward trusted headers, and set `APP_HOST`/`FORCE_SSL=true`. PostgreSQL
and Active Storage named volumes must reside on persistent disk.

Use systemd (or the host's equivalent) to supervise
`docker compose up --remove-orphans`, with explicit restart and boot ordering.
Pull/build the new immutable image, run the release service once, and then
replace web/worker. Do not expose the database. Configure Docker log rotation
and host monitoring.
