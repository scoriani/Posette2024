# failover from primary to geo-replica
az postgres flexible-server replica promote -g <rg_name> -n <secondary_name> --promote-mode switchover --promote-option forced

# failback from geo-replica to primary
az postgres flexible-server replica promote -g <rg_name> -n <primary_name> --promote-mode switchover --promote-option forced

# re-enable local high availability on primary
az postgres flexible-server update -g <rg_name> -n <primary_name> --high-availability ZoneRedundant --standby-zone 1
