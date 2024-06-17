
SELECT
  inet_server_addr() as replica_address,
  setting,
  pg_is_in_recovery() AS is_slave,
  pg_last_wal_receive_lsn() = pg_last_wal_replay_lsn() AS synced,
  (
   EXTRACT(EPOCH FROM now()) -
   EXTRACT(EPOCH FROM pg_last_xact_replay_timestamp())
  )::int AS lag
  FROM pg_settings where name = 'primary_conninfo';

SELECT * FROM pg_settings where name ilike 'repl%'

SELECT
  pg_is_in_recovery() AS is_slave,
  pg_last_wal_receive_lsn() AS receive,
  pg_last_wal_replay_lsn() AS replay,
  pg_last_wal_receive_lsn() = pg_last_wal_replay_lsn() AS synced,
  EXTRACT(SECONDS FROM now() - pg_last_xact_replay_timestamp())::float AS lag


  SELECT inet_server_addr();

  SELECT * FROM pg_settings where name ilike 'primary%';

  SELECT * FROM test;