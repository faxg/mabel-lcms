param location string
param environmentType string
param databaseName string
param databaseAdminLogin string
@secure()
param databaseAdminPassword string

param environmentConfigurationMap object

// https://learn.microsoft.com/en-us/azure/templates/microsoft.dbforpostgresql/flexibleservers?pivots=deployment-language-bicep
// Docs:  https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/quickstart-create-server-bicep?toc=%2Fazure%2Fazure-resource-manager%2Fbicep%2Ftoc.json&tabs=CLI
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2023-12-01-preview' = {
  name: databaseName
  location: location

  // See: https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-compute#compute-tiers-vcores-and-server-types
  sku: environmentConfigurationMap[environmentType].database.sku
  properties: {
    version: '12'
    administratorLogin: databaseAdminLogin
    administratorLoginPassword: databaseAdminPassword
    storage: {
      autoGrow:'Enabled' 
      storageSizeGB: 64
    }
  }

  identity: {
    type: 'SystemAssigned'
  }
}

resource database 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2023-12-01-preview' = {
  name: 'payloadcms'
  parent: postgresServer

  properties: {
    charset: 'UTF8'
    collation: 'en_US.utf8'
  }
}


// https://learn.microsoft.com/en-us/azure/templates/microsoft.dbforpostgresql/flexibleservers?pivots=deployment-language-bicep

@description('The FQN of the PostgreSQL Server.')
output postgresServerName string = postgresServer.properties.fullyQualifiedDomainName
@description('Administrator login username for the PostgreSQL Server.')
output postgresServerAdministratorLogin string = postgresServer.properties.administratorLogin


