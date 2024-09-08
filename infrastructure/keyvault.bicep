param prefix string
param location string

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: '${prefix}-keyvault'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
  }
}

output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
