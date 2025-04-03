docker pull postgres

docker create --name postgres-cont -e POSTGRES_PASSWORD=root postgres
docker start postgres-cont
docker exec -it postgres-cont /bin/bash

initdb -D $PGDATA --encoding=$PGENCODING --locale=$PGLOCALE

настроили порт 9193 в 
$PGDATA/postgresql.conf

pg_ctl -D $PGDATA start

настроили в $PGDATA/pg_hba.conf
# Разрешить подключение через Unix-domain сокет в режиме peer
local   all             all                                     peer

# Разрешить подключение через TCP/IP только для localhost с аутентификацией по паролю SHA-256
host    all             all             127.0.0.1/32            scram-sha-256

# Запретить все остальные способы подключений
host    all             all             0.0.0.0/0               reject

изменили host    all             all             0.0.0.0/0               reject

$PGDATA/postgresql.conf

listen_addresses = 'localhost'  
unix_socket_directories = '/var/run/postgresql' 
port = 9193
max_connections = 300  
shared_buffers = 8GB  
temp_buffers = 64MB  
work_mem = 32MB  
checkpoint_timeout = 15min 
effective_cache_size = 24GB  
fsync = on  
commit_delay = 10ms  
wal_buffers = 16MB  
log_destination = 'stderr'  
logging_collector = on  
log_directory = 'log'  
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log' 
log_file_mode = 0600 
log_truncate_on_rotation = on 
log_rotation_age = 1d 
log_rotation_size = 100MB 
log_min_messages = warning  
log_checkpoints = on 
log_connections = on 


postgres@d3ca4b40f616:/$ pg_ctl -D $PGDATA restart
waiting for server to shut down....2025-03-07 09:47:21.240 UTC [3230] СООБЩЕНИЕ:  получен запрос на быстрое выключение
2025-03-07 09:47:21.250 UTC [3230] СООБЩЕНИЕ:  прерывание всех активных транзакций
2025-03-07 09:47:21.253 UTC [3230] СООБЩЕНИЕ:  фоновый процесс "logical replication launcher" (PID 3236) завершился с кодом выхода 1
2025-03-07 09:47:21.254 UTC [3231] СООБЩЕНИЕ:  выключение
2025-03-07 09:47:21.256 UTC [3231] СООБЩЕНИЕ:  начата контрольная точка: shutdown immediate
2025-03-07 09:47:21.261 UTC [3231] СООБЩЕНИЕ:  контрольная точка завершена: записано буферов: 0 (0.0%); добавлено файлов WAL 0, удалено: 0, переработано: 0; запись=0.001 сек., синхр.=0.001 сек., всего=0.007 сек.; синхронизировано_файлов=0, самая_долгая_синхр.=0.000 сек., средняя=0.000 сек.; расстояние=0 kB, ожидалось=0 kB; lsn=0/1527F70, lsn redo=0/1527F70
2025-03-07 09:47:21.269 UTC [3230] СООБЩЕНИЕ:  система БД выключена
 done
server stopped
waiting for server to start....2025-03-07 09:47:21.562 UTC [3290] СООБЩЕНИЕ:  передача вывода в протокол процессу сбора протоколов
2025-03-07 09:47:21.562 UTC [3290] ПОДСКАЗКА:  В дальнейшем протоколы будут выводиться в каталог "log".
 done
server started


postgres@d3ca4b40f616:/$ psql -d postgres
psql (17.4 (Debian 17.4-1.pgdg120+2))
Type "help" for help.

postgres=# SHOW max_connections;
SHOW shared_buffers;
SHOW temp_buffers;
SHOW work_mem;
SHOW checkpoint_timeout;
SHOW effective_cache_size;
SHOW fsync;
SHOW commit_delay;
SHOW wal_dir;
SHOW log_destination;
SHOW log_min_messages;
SHOW log_checkpoints;
SHOW log_connections;
 max_connections 
-----------------
 100
(1 row)

 shared_buffers 
----------------
 128MB
(1 row)

 temp_buffers 
--------------
 8MB
(1 row)

 work_mem 
----------
 4MB
(1 row)

 checkpoint_timeout 
--------------------
 5min
(1 row)

 effective_cache_size 
----------------------
 4GB
(1 row)

 fsync 
-------
 on
(1 row)

 commit_delay 
--------------
 0
(1 row)

ERROR:  unrecognized configuration parameter "wal_dir"
 log_destination 
-----------------
 stderr
(1 row)

 log_min_messages 
------------------
 warning
(1 row)

 log_checkpoints 
-----------------
 on
(1 row)

 log_connections 
-----------------
 off
(1 row)

Создать новые табличные пространства для различных таблиц: $HOME/yva58, $HOME/yrp30, $HOME/sgk31

mkdir -p $HOME/yva58 $HOME/yrp30 $HOME/sgk31
chown postgres:postgres $HOME/yva58 $HOME/yrp30 $HOME/sgk31
chmod 700 $HOME/yva58 $HOME/yrp30 $HOME/sgk31

psql -p 9193 -U postgres -c "CREATE TABLESPACE yva58 LOCATION '$HOME/yva58';"
psql -p 9193 -U postgres -c "CREATE TABLESPACE yrp30 LOCATION '$HOME/yrp30';"
psql -p 9193 -U postgres -c "CREATE TABLESPACE sgk31 LOCATION '$HOME/sgk31';"

На основе template0 создать новую базу: fatrednews
psql -p 9193 -U postgres -c "CREATE DATABASE fatrednews TEMPLATE template0;"

psql -p 9193 -U postgres -c "CREATE ROLE fatreduser WITH LOGIN PASSWORD 'changeMe';"
psql -p 9193 -U postgres -c "GRANT CONNECT ON DATABASE fatrednews TO fatreduser;"
psql -p 9193 -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE fatrednews TO fatreduser;"

Создать новую роль, предоставить необходимые права, разрешить подключение к базе.

psql -U postgres -d fatrednews
GRANT USAGE ON SCHEMA public TO fatreduser;
GRANT CREATE ON SCHEMA public TO fatreduser;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO fatreduser;

-- Таблица в табличном пространстве yva58
CREATE TABLE table_yva58 (
    id SERIAL PRIMARY KEY,
    data TEXT
) TABLESPACE yva58;

-- Таблица в табличном пространстве yrp30
CREATE TABLE table_yrp30 (
    id SERIAL PRIMARY KEY,
    data TEXT
) TABLESPACE yrp30;

-- Таблица в табличном пространстве sgk31
CREATE TABLE table_sgk31 (
    id SERIAL PRIMARY KEY,
    data TEXT
) TABLESPACE sgk31;

GRANT ALL ON TABLESPACE yva58 TO fatreduser;
GRANT ALL ON TABLESPACE yrp30 TO fatreduser;
GRANT ALL ON TABLESPACE sgk31 TO fatreduser;

От имени новой роли (не администратора) произвести наполнение ВСЕХ созданных баз тестовыми наборами данных. ВСЕ табличные пространства должны использоваться по назначению.
-- Наполнение таблицы table_yva58
INSERT INTO table_yva58 (data) VALUES ('Тестовые данные для yva58');

-- Наполнение таблицы table_yrp30
INSERT INTO table_yrp30 (data) VALUES ('Тестовые данные для yrp30');

-- Наполнение таблицы table_sgk31
INSERT INTO table_sgk31 (data) VALUES ('Тестовые данные для sgk31');

SELECT * FROM table_yva58;
SELECT * FROM table_yrp30;
SELECT * FROM table_sgk31;

Список табличных пространств
\db+ 

Вывести список всех табличных пространств кластера и содержащиеся в них объекты.
fatrednews=# SELECT spcname AS tablespace, relname AS object_name, relkind AS type
FROM pg_class
JOIN pg_tablespace ON pg_class.reltablespace = pg_tablespace.oid
WHERE spcname IN ('yva58', 'yrp30', 'sgk31');
 tablespace |     object_name      | type 
------------+----------------------+------
 yva58      | pg_toast_16404       | t
 yva58      | pg_toast_16404_index | i
 yva58      | table_yva58          | r
 yrp30      | pg_toast_16413       | t
 yrp30      | pg_toast_16413_index | i
 yrp30      | table_yrp30          | r
 sgk31      | pg_toast_16422       | t
 sgk31      | pg_toast_16422_index | i
 sgk31      | table_sgk31          | r

посмотреть pg_toast_16413


 timescale db накатить на postgres и загрузить туда курсы валют и потестить разнизу между postgres и timescale db.
 простые запросы
 запросы с функциями
 explain analyze