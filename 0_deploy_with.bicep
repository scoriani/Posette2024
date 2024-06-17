param flexibleServers_primary_name string
param flexibleServers_secondary_name string

resource flexibleServers_primary 'Microsoft.DBforPostgreSQL/flexibleServers@2023-06-01-preview' = {
  location: '<location_primary>'
  name: flexibleServers_primary_name
  properties: {
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Disabled'
      tenantId: '<tenantid>'
    }
    availabilityZone: '1'
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    dataEncryption: {
      type: 'SystemManaged'
    }
    highAvailability: {
      mode: 'ZoneRedundant'
      standbyAvailabilityZone: '3'
    }
    maintenanceWindow: {
      customWindow: 'Disabled'
      dayOfWeek: 0
      startHour: 0
      startMinute: 0
    }
    network: {
      publicNetworkAccess: 'Enabled'
    }
    replica: {
      role: 'Primary'
    }
    replicationRole: 'Primary'
    storage: {
      autoGrow: 'Disabled'
      iops: 120
      storageSizeGB: 32
      tier: 'P4'
    }
    version: '16'
  }
  sku: {
    name: 'Standard_D2s_v3'
    tier: 'GeneralPurpose'
  }
  tags: {
    key: 'value'
  }
  resource database 'databases' = {
    name: 'testdb'
  }
}

resource flexibleServers_secondary 'Microsoft.DBforPostgreSQL/flexibleServers@2023-06-01-preview' = {
  location: '<location_secondary>'
  name: flexibleServers_secondary_name
  properties: {
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Disabled'
      tenantId: '<tenantid>'
    }
    availabilityZone: '1'
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    dataEncryption: {
      type: 'SystemManaged'
    }
    highAvailability: {
      mode: 'Disabled'
    }
    maintenanceWindow: {
      customWindow: 'Disabled'
      dayOfWeek: 0
      startHour: 0
      startMinute: 0
    }
    network: {
      publicNetworkAccess: 'Enabled'
    }
    replica: {
      role: 'GeoAsyncReplica'
    }
    replicationRole: 'GeoAsyncReplica'
    sourceServerResourceId: flexibleServers_primary.id
    storage: {
      autoGrow: 'Disabled'
      iops: 120
      storageSizeGB: 32
      tier: 'P4'
    }
    version: '16'
  }
  sku: {
    name: 'Standard_D2s_v3'
    tier: 'GeneralPurpose'
  }
  tags: {
    key: 'value'
  }
}

resource flexibleServers_primary_administrators 'Microsoft.DBforPostgreSQL/flexibleServers/administrators@2023-06-01-preview' = {
  parent: flexibleServers_primary
  name: '<user_guid>'
  properties: {
    principalName: '<user_name>'
    principalType: 'User'
    tenantId: '<tenantid>'
  }
}

resource flexibleServers_secondary_administrators 'Microsoft.DBforPostgreSQL/flexibleServers/administrators@2023-06-01-preview' = {
  parent: flexibleServers_secondary
  name: '<user_guid>'
  properties: {
    principalName: '<user_name>'
    principalType: 'User'
    tenantId: '<tenantid>'
  }
}

resource flexibleServers_primary_AllowAllAzureServices 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2023-06-01-preview' = {
  parent: flexibleServers_primary
  name: 'AllowAllAzureServices_primary'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

resource flexibleServers_secondary_AllowAllAzureServices 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2023-06-01-preview' = {
  parent: flexibleServers_secondary
  name: 'AllowAllAzureServices_secondary'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

resource flexibleServers_primary_ClientIPAddress 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2023-06-01-preview' = {
  parent: flexibleServers_primary
  name: 'ClientIPAddress_primary'
  properties: {
    endIpAddress: '195.32.127.60'
    startIpAddress: '195.32.127.60'
  }
}

resource flexibleServers_secondary_ClientIPAddress 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2023-06-01-preview' = {
  parent: flexibleServers_secondary
  name: 'ClientIPAddress_secondary'
  properties: {
    endIpAddress: '195.32.127.60'
    startIpAddress: '195.32.127.60'
  }
}

resource flexibleServers_primary_scoriani_virtual_endpoint 'Microsoft.DBforPostgreSQL/flexibleServers/virtualendpoints@2023-06-01-preview' = {
  parent: flexibleServers_primary
  name: '<virtual_endpoint_name>'
  properties: {
    endpointType: 'ReadWrite'
    members: [
      flexibleServers_secondary_name
    ]
  }
}
