# create resource group
az group create --name <resourcegroup> --location <region1>

# create primary instance with zone-enabled replica
az postgres flexible-server create \
  --location <region1> --resource-group <resourcegroup> --name <primary> \
  --active-directory-auth Enabled --password-auth Disabled \
  --public-access 0.0.0.0 --storage-size 32 --tags "key=value" --version 16 \
  --high-availability ZoneRedundant --zone 1 --standby-zone 3

# add flexible-server admin user with Entra ID account
  az postgres flexible-server ad-admin create -g <resourcegroup> -s <primary> \
   -u <AADUser> -i <AADId> -t User

# add geo-replica in a different region
az postgres flexible-server replica create --replica-name <secondary> \ 
 -g <resourcegroup> --source-server <primary> --zone 3 --location <region2>

# create virtual endpoint
az postgres flexible-server virtual-endpoint create --resource-group <resourcegroup> \
 --server-name <primary> --name <endpoint-name> \
 --endpoint-type ReadWrite --members <secondary>