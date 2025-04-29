        # Примерное содержимое ./primary/init-as-replica.sh
        #!/bin/bash
        set -e
        echo "Waiting for current primary (pg-replica)..."
        # Используйте имя пользователя/БД, которые существуют на pg-replica
        until pg_isready -h pg-replica -p 5432 -U "$POSTGRES_USER" -d "$POSTGRES_DB"; do
          sleep 1
        done
        echo "Current primary (pg-replica) is ready."
        # Очистка не нужна, т.к. volume удален и будет пуст
        # rm -rf "$PGDATA"/*
        mkdir -p "$PGDATA"
        echo "Running pg_basebackup from pg-replica..."
        # Используйте пользователя репликации
        pg_basebackup \
          --host=pg-replica \
          --port=5432 \
          --username="$REPLICATOR_USER" \
          --pgdata="$PGDATA" \
          --wal-method=stream \
          --progress \
          --verbose \
          --checkpoint=fast \
          --write-recovery-conf

        echo "Base backup complete. Ensuring standby configuration..."
        echo "listen_addresses = '*'" | tee -a "$PGDATA/postgresql.auto.conf" > /dev/null
        echo "hot_standby = on" | tee -a "$PGDATA/postgresql.auto.conf" > /dev/null
        # Права должны быть ОК, но для уверенности:
        find "$PGDATA" -exec chown postgres:postgres {} + || echo "Chown failed"
        chmod 0700 "$PGDATA"
        echo "Old primary initialized as replica. PostgreSQL will start in standby mode."