    #!/bin/bash
    set -e

    # Используем переменные окружения, переданные в docker-compose
    # POSTGRES_USER и POSTGRES_DB гарантированно существуют на этом этапе
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        DO \$\$
        BEGIN
           IF NOT EXISTS (
              SELECT FROM pg_catalog.pg_roles
              WHERE  rolname = '${REPLICATOR_USER}') THEN

              CREATE USER ${REPLICATOR_USER} WITH REPLICATION PASSWORD '${REPLICATOR_PASSWORD}';
           ELSE
              ALTER USER ${REPLICATOR_USER} WITH REPLICATION PASSWORD '${REPLICATOR_PASSWORD}';
           END IF;
        END
        \$\$;
    EOSQL

    echo "Replication user ${REPLICATOR_USER} ensured."
