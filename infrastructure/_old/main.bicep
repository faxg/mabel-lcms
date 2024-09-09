targetScope = 'subscription'

@description('Prefix for all resources, may get sanitized if neded (SA names...). Default "mabel-lcms". ')
@minLength(4)
@maxLength(14)
param prefix string = 'mabel-lcms'

@description('Location for all resources. Default "westeurope"')
param location string = 'westeurope'

@description('The administrator login for the PostgreSQL server. Default "admin"')
@minLength(3)
param administratorLogin string = 'mabeladmin'

@description('The password for the PostgreSQL server.')
@secure()
param administratorLoginPassword string

/**
* The resource group. Every Mabel service instance resides fully under one resource group."
*/
resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: '${prefix}-rg'
  location: location
}

// resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
//   name: keyVaultName
// }


/**
* Key Vault Module
*/
module keyVaultModule './keyvault.bicep' = {
  name: 'keyVaultDeployment'
  scope: resourceGroup(rg.name)

  params: {
    prefix: prefix
  }
}


output keyVault object = keyVaultModule.outputs.keyVault


/**
* The storage account for the Mabel instance.
*/
module storageAccountModule './storage.bicep' = {
  name: 'storageAccountDeployment'
  scope: resourceGroup(rg.name)
  dependsOn:  [keyVaultModule]

  params: {    
    prefix: prefix
  }

}

module postgresServerModule './database.bicep' = {
  name: 'postgresServerDeployment'
  scope: resourceGroup(rg.name)
  dependsOn:  [keyVaultModule]

  params: {
    prefix: prefix
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}

module containerRegistryModule './registry.bicep' = {
  name: 'containerRegistryDeployment'
  scope: resourceGroup(rg.name)
  dependsOn:  [keyVaultModule]

  params: {
    prefix: prefix
  }
}



module containerAppModule './containerapp.bicep' = {
  name: 'containerAppDeployment'
  scope: resourceGroup(rg.name)
  params: {
    prefix: prefix
    containerRegistryName: containerRegistryModule.outputs.containerRegistryName 
    containerImageName: '${prefix}-image' 
  }
}
