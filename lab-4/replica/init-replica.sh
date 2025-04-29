    #!/bin/bash
    set -e

    # Проверяем, что первичный сервер доступен
    until pg_isready -h primary -p 5432 -U "$POSTGRES_USER"
    do
      echo "Waiting for primary node to start..."
      sleep 1s
    done

    echo "Primary node started."

    # Удаляем содержимое $PGDATA, если оно есть, чтобы pg_basebackup сработал
    rm -rf "$PGDATA"/*

    echo "Running pg_basebackup..."
    # Выполняем базовое резервное копирование с основного узла
    pg_basebackup \
      --host=primary \
      --port=5432 \
      --username="$REPLICATOR_USER" \
      --pgdata="$PGDATA" \
      --wal-method=stream \
      --progress \
      --verbose \
      --checkpoint=fast \
      --write-recovery-conf # Эта опция автоматически создаст standby.signal и postgresql.auto.conf с primary_conninfo

    # --write-recovery-conf автоматически добавит primary_conninfo в postgresql.auto.conf
    # Формируем primary_conninfo строку. Используем $REPLICATOR_PASSWORD из переменных окружения.
    echo "primary_conninfo = 'host=primary user=${REPLICATOR_USER} password=${REPLICATOR_PASSWORD} port=5432 sslmode=prefer sslcompression=0 gssencmode=disable target_session_attrs=any'" >> "$PGDATA/postgresql.auto.conf"

    # Убеждаемся, что права на $PGDATA правильные
    chmod 0700 "$PGDATA"

    echo "Replica initialized. Starting PostgreSQL in standby mode..."
    # Запуск postgres будет выполнен основной точкой входа образа docker postgres