#!/bin/bash
set -e

rm -rf "$PGDATA"/*

echo "Запуск pg_basebackup..."
pg_basebackup \
    --host=primary \
    --port=5432 \
    --username="$REPLICATOR_USER" \
    --pgdata="$PGDATA" \
    --wal-method=stream \
    --progress \ 
    --verbose \ 
    --write-recovery-conf # автоматически создаст standby.signal и postgresql.auto.conf с primary_conninfo


echo "Реплика запущена и настроена..."
