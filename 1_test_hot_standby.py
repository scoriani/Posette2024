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
        conn_string = "host={0} user={1} dbname={2} password={3} sslmode={4} connect_timeout=5 options='-c statement_timeout=5000'".format(host, user, dbname,token_bytes, sslmode)
        conn = psycopg2.connect(conn_string)
        return conn
    except (Exception, psycopg2.DatabaseError) as error:
        print("%s - connection error: %s" % (datetime.now().strftime("%d/%m/%Y %H:%M:%S"), error))

# Update connection string information
host_primary = "<virtual_endpoint_name>.writer.postgres.database.azure.com"
dbname = "<database_name>"
user = "<user_name>"
sslmode = "require"

# Construct connection string
conn_primary = get_conn(host_primary) 

print("Connection established")
if conn_primary is not None:
    cursor_primary = conn_primary.cursor()

while True:
    try:
        # Query primary
        cursor_primary.execute('SELECT "current_user"(),inet_server_addr() as primary_address, slot_name as standby_server FROM pg_replication_slots where slot_name ilike \'azure_standby%\';')
        rows_primary = cursor_primary.fetchall()
        # Print all rows
        for row_primary in rows_primary:
                print("%s - user: %s primary_ip: %s standby_name: %s \n" % (datetime.now().strftime("%d/%m/%Y %H:%M:%S"), str(row_primary[0]), str(row_primary[1]), str(row_primary[2])))

    except (Exception, psycopg2.DatabaseError) as error:
        print("%s - cursor error: %s" % (datetime.now().strftime("%d/%m/%Y %H:%M:%S"), error))
        conn_primary = get_conn(host_primary)
        if conn_primary is not None:
            cursor_primary = conn_primary.cursor()

    time.sleep(1)    

# Cleanup
conn_primary.commit()
cursor_primary.close()
conn_primary.close()
