#!/bin/bash
set -e

DEFAULT_PGDATA="/var/lib/postgresql/data"

echo "$POSTGRES_PASSWORD" > /tmp/pgpass
chmod 777 /tmp/pgpass

runuser -u postgres -- initdb --username="${POSTGRES_USER}" --pwfile=/tmp/pgpass -D "$PGDATA" --auth=password

rm /tmp/pgpass
echo "Инициализация кластера завершена."

exec runuser -u postgres -- "$@"