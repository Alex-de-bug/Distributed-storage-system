#!/bin/bash
set -e

DEFAULT_PGDATA="/var/lib/postgresql/data"

if [ ! -f "$PGDATA/PG_VERSION" ]; then
    echo "Инициализация базы данных PostgreSQL..."

    echo "$POSTGRES_PASSWORD" > /tmp/pgpass
    chmod 777 /tmp/pgpass

    runuser -u postgres -- initdb --username="${POSTGRES_USER:-postgres}" --pwfile=/tmp/pgpass -D "$PGDATA" --auth=password

    rm /tmp/pgpass
    echo "Инициализация кластера завершена."
else
    echo "База данных уже инициализирована, пропускаем initdb."
fi

echo "Запуск PostgreSQL..."
exec runuser -u postgres -- "$@"