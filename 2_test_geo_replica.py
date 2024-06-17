import os
import time
from datetime import datetime
import struct
from azure.identity import DefaultAzureCredential
import urllib.parse

import psycopg2

def get_conn(host):
    try:
        credential = DefaultAzureCredential(exclude_interactive_browser_credential=False)
        token_bytes = credential.get_token("https://ossrdbms-aad.database.windows.net/.default").token
        conn_string = "host={0} user={1} dbname={2} password={3} sslmode={4}".format(host, user, dbname,token_bytes, sslmode)
        conn = psycopg2.connect(conn_string)
        return conn
    except (Exception, psycopg2.DatabaseError) as error:
        print("%s - connection error: %s" % (datetime.now().strftime("%d/%m/%Y %H:%M:%S"), error))

# Update connection string information
host_primary = "<virtual_endpoint_name>.writer.postgres.database.azure.com"
host_replica = "<virtual_endpoint_name>.reader.postgres.database.azure.com"
dbname = "<database_name>"
user = "<user_name>"
sslmode = "require"

# Construct connection string
conn_primary = get_conn(host_primary) 
conn_replica = get_conn(host_replica)

print("Connection established")
if conn_primary is not None:
    cursor_primary = conn_primary.cursor()
if conn_replica is not None:
    cursor_replica = conn_replica.cursor()

while True:
    try:
        # Query primary
        cursor_primary.execute('SELECT "current_user"(),inet_server_addr() as primary_address, slot_name as standby_server FROM pg_replication_slots where slot_name ilike \'azure_%\';')
        rows_primary = cursor_primary.fetchall()
        # Query replica
        cursor_replica.execute('''SELECT
                                inet_server_addr() as replica_address,
                                setting,
                                pg_is_in_recovery() AS is_slave,
                                pg_last_wal_receive_lsn() = pg_last_wal_replay_lsn() AS synced,
                                (
                                EXTRACT(EPOCH FROM now()) -
                                EXTRACT(EPOCH FROM pg_last_xact_replay_timestamp())
                                )::int AS lag
                                FROM pg_settings where name = \'primary_conninfo\';''')
        rows_replica = cursor_replica.fetchall()
        # Print all rows
        for row_primary in rows_primary:
            for row_replica in rows_replica:
                print("%s - user: %s primary_ip: %s standby_name: %s geo_replica_ip: %s geo_replica_settings: %s geo_replica_synch: %s \n" % (datetime.now().strftime("%d/%m/%Y %H:%M:%S"), str(row_primary[0]), str(row_primary[1]), str(row_primary[2]), str(row_replica[0]), str(row_replica[1])[:93], str(row_replica[3])))

    except (Exception, psycopg2.DatabaseError) as error:
        print("%s - cursor error: %s" % (datetime.now().strftime("%d/%m/%Y %H:%M:%S"), error))
        conn_primary = get_conn(host_primary)
        conn_replica = get_conn(host_replica)
        if conn_primary is not None:
            cursor_primary = conn_primary.cursor()
        if conn_replica is not None:
            cursor_replica = conn_replica.cursor()

    time.sleep(1)    

# Cleanup
conn_primary.commit()
conn_replica.commit()
cursor_primary.close()
cursor_replica.close()
conn_primary.close()
conn_replica.close()

