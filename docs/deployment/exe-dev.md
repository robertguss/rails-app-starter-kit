# exe.dev

Run the checked-in Compose topology on one persistent VM. Put the web port
behind exe.dev's supervised HTTPS proxy; do not expose PostgreSQL, storage, or
worker ports. Keep the Compose project and its named PostgreSQL/storage volumes
on persistent disk. Supply secrets through the VM's protected environment file,
not Compose source control.

Supervise `docker compose up --build --remove-orphans` with the host facility,
and schedule `bin/backup` plus off-host transfer independently. The release
one-shot must succeed before web/worker start. Confirm the platform's current
proxy, persistence, restart, and certificate behavior before use. No exe.dev
instance was created because no disposable target or credentials were approved.
