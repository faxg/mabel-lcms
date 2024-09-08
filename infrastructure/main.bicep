targetScope = 'subscription'

@description('Prefix for all resources. Default "mabel-lcms"')
param prefix string = 'mabel-lcms'
@description('Location for all resources. Default "westeurope"')
param location string = 'westeurope'
@description('The administrator login for the PostgreSQL server. Default "admin"')
param administratorLogin string = 'admin'

@description('The password for the PostgreSQL server.')
@secure()
param administratorLoginPassword string


resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: '${prefix}-rg'
  location: location
}

module storageAccountModule './storage.bicep' = {
  name: 'storageAccountDeployment'
  scope: resourceGroup(rg.name)
  params: {
    prefix: prefix
    location: location
  }
}

module postgresServerModule './database.bicep' = {
  name: 'postgresServerDeployment'
  scope: resourceGroup(rg.name)
  params: {
    prefix: prefix
    location: location
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}

module containerRegistryModule './registry.bicep' = {
  name: 'containerRegistryDeployment'
  scope: resourceGroup(rg.name)
  params: {
    prefix: prefix
    location: location
  }
}


module keyVaultModule './keyvault.bicep' = {
  name: 'keyVaultDeployment'
  scope: resourceGroup(rg.name)
  params: {
    prefix: prefix
    location: location
  }
}

