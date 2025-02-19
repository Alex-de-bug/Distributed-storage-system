CREATE OR REPLACE PROCEDURE show_files() LANGUAGE plpgsql AS $$
DECLARE
    X record;
BEGIN

    RAISE NOTICE 'No. FILE#      NAME      MODIFICATION_TIME           SPACE';
    RAISE NOTICE '--- ---------- -------   ---------------------       ------------';

    FOR X IN (
        select 
            ROW_NUMBER() OVER (ORDER BY(relfilenode)) as n, 
            relfilenode as node, 
            relname as rname, 
            (pg_stat_file(pg_relation_filepath(pg_class.oid))).modification as modif, 
            nspname as spac
        from pg_class 
        join pg_namespace on pg_namespace.oid = pg_class.relnamespace 
        where relkind = 'r' and nspname != 'pg_catalog' and nspname != 'information_schema'
    ) LOOP
        RAISE NOTICE '%    %    %    %    %',
            X.n::text,
            X.node::text,
            X.rname,
            to_char(X.modif::timestamp, 'YYYY-MM-DD HH24:MI:SS'),
            X.spac;
    END LOOP;
END;
$$;


CREATE OR REPLACE PROCEDURE show_files() LANGUAGE plpgsql AS $$
DECLARE
    X record;
BEGIN

    RAISE NOTICE 'No. FILE#      NAME           SPACE';
    RAISE NOTICE '--- ---------- -------        ------------';

    FOR X IN (
        select 
            ROW_NUMBER() OVER (ORDER BY(relfilenode)) as n, 
            relfilenode as node, 
            relname as rname
            nspname as spac
        from pg_class 
        join pg_namespace on pg_namespace.oid = pg_class.relnamespace 
        where relkind = 'r' and nspname != 'pg_catalog' and nspname != 'information_schema'
    ) LOOP
        RAISE NOTICE '%    %    %    %',
            X.n::text,
            X.node::text,
            X.rname,
            X.spac;
    END LOOP;
END;
$$;
