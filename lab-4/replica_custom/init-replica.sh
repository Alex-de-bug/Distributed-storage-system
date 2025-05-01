#!/bin/bash
set -e

echo "Primary node started."

rm -rf "$PGDATA"/*

pg_basebackup \
  --host=replica \
  --port=5433 \
  --username="$REPLICATOR_USER" \
  --pgdata="$PGDATA" \
  --wal-method=stream \
  --progress \
  --verbose \
  --checkpoint=fast \
  --write-recovery-conf 

# --write-recovery-conf автоматически добавит primary_conninfo в postgresql.auto.conf
# Формируем primary_conninfo строку. Используем $REPLICATOR_PASSWORD из переменных окружения.
echo "primary_conninfo = 'host=primary user=${REPLICATOR_USER} password=${REPLICATOR_PASSWORD} port=5432 sslmode=prefer sslcompression=0 gssencmode=disable target_session_attrs=any'" >> "$PGDATA/postgresql.auto.conf"

chmod 0700 "$PGDATA"

echo "Replica initialized. Starting PostgreSQL in standby mode..."
