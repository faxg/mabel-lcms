param prefix string

param administratorLogin string
@secure()
param administratorLoginPassword string

// https://learn.microsoft.com/en-us/azure/templates/microsoft.dbforpostgresql/flexibleservers?pivots=deployment-language-bicep
// Docs:  https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/quickstart-create-server-bicep?toc=%2Fazure%2Fazure-resource-manager%2Fbicep%2Ftoc.json&tabs=CLI

resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2023-12-01-preview' = {
  name: '${prefix}-dbserver'
  location: resourceGroup().location

  // See: https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-compute#compute-tiers-vcores-and-server-types
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  
  properties: {
    version: '12'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
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

output postgresServerName string = postgresServer.name
output postgresServerFqdn string = postgresServer.properties.fullyQualifiedDomainName
output postgresServerIdentity object = postgresServer.identity

output postgresDatabaseName string = database.name
output postgresDatabaseId string = database.id
