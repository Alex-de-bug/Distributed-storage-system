#!/bin/bash
set -e

if [ ! -f "$PGDATA/PG_VERSION" ]; then
    # echo "Инициализация базы данных PostgreSQL..."

    # echo "$POSTGRES_PASSWORD" > /tmp/pgpass
    # chmod 777 /tmp/pgpass

    # runuser -u postgres -- initdb --username="$POSTGRES_USER" --pwfile=/tmp/pgpass -D "$PGDATA" --auth=password

    # rm /tmp/pgpass

    # cp /etc/postgresql/data/postgresql.conf "$PGDATA/postgresql.conf"
    # cp /etc/postgresql/data/pg_hba.conf "$PGDATA/pg_hba.conf"

    # echo "Инициализация кластера завершена."
    rm -rf "$PGDATA"/*
    echo "Запуск pg_basebackup..."
    runuser -u postgres -- bash -c "pg_basebackup -h primary -p 5432 -U $POSTGRES_USER -D $PGDATA -X stream -P -v -R"
else
    echo "База данных уже инициализирована, пропускаем initdb."
fi

echo "Запуск PostgreSQL..."
exec runuser -u postgres -- "$@"