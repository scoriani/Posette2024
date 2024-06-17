-- Get Primary IP address
SELECT "current_user"(),inet_server_addr();

-- Get Replication Slots for Local HA Standby Server and Remote Geo-DR Read Replica
SELECT "current_user"(),inet_server_addr() as primary_address, slot_name as standby_server FROM pg_replication_slots where slot_name ilike 'azure_%';

-- Create a test table
CREATE TABLE IF NOT EXISTS test (id int);

-- Insert a row
INSERT INTO test VALUES (1);

-- Select
SELECT * FROM test;
