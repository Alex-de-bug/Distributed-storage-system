FROM debian:12

RUN apt-get update && apt-get install -y postgresql-15

COPY pg_hba.conf /var/lib/postgresql/data/pg_hba.conf
COPY postgresql.conf /var/lib/postgresql/data/postgresql.conf
COPY init-replica.sh /docker-entrypoint-initdb.d/init-replica.sh
RUN chmod +x /docker-entrypoint-initdb.d/init-replica.sh




ENV POSTGRES_DB=mydatabase \
    POSTGRES_USER=user \
    POSTGRES_PASSWORD=password \
    REPLICATOR_USER=replicator \
    REPLICATOR_PASSWORD=replicator_password \
    PGDATA=/var/lib/postgresql/data
