param prefix string
param location string

param administratorLogin string
@secure()
param administratorLoginPassword string

// https://learn.microsoft.com/en-us/azure/templates/microsoft.dbforpostgresql/flexibleservers?pivots=deployment-language-bicep
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2023-12-01-preview' = {
  name: '${prefix}-db-server'
  location: location
  sku: {
    name: 'Standard_B2ms'
    tier: 'GeneralPurpose'
  }

  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    version: '11'
    createMode: 'Default'
  }
}

resource database 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2023-12-01-preview' = {
  name: '${prefix}-database'
  parent: postgresServer

  properties: {
    charset: 'UTF8'
    collation: 'en_US.utf8'
  }
}


output postgresServerName string = postgresServer.name
output postgresServerFqdn string = postgresServer.properties.fullyQualifiedDomainName
output postgresServerTenantId string = postgresServer.properties.authConfig.tenantId

output postgresDatabaseName string = database.name
output postgresDatabaseId string = database.id
