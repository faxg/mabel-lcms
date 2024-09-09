param prefix string

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: '${prefix}-keyvault'
  location: resourceGroup().location
  
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    //enableSoftDelete: false
    //enablePurgeProtection: false


  }

}

resource keyVaultSecrets 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  name: 'administratorLogin'
  parent: keyVault
  properties: {
    value: 'mabeladmin'
  }
}



output keyVault object = keyVault
output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
