param location string
param keyVaultName string

param environmentType string
param environmentConfigurationMap object



resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: keyVaultName
  location: location
  
  
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enableSoftDelete: false
    enablePurgeProtection: false
  }

}

resource keyVaultSecrets 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  name: 'administratorLogin'
  parent: keyVault
  properties: {
    value: 'mabeladmin'
  }
}




output keyVaultUri string = keyVault.properties.vaultUri
