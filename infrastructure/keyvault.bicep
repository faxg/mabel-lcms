param location string
param keyVaultName string

param environmentType string
param environmentConfigurationMap object

// see: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/scenarios-secrets


resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: keyVaultName
  location: location
  
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    
    
    enableSoftDelete: false
    //enablePurgeProtection: false
  }

}



resource keyVaultSecrets 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  parent: keyVault

  name: 'administratorLogin'
  properties: {
    value: 'mabeladmin'
  }
}

// @description('Specifies all secrets {"secretName":"","secretValue":""} wrapped in a secure object.')
// @secure()
// param secretsObject object


// resource secrets 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = [for secret in secretsObject.secrets: {
//   name: secret.secretName
//   parent: keyVault
//   properties: {
//     value: secret.secretValue
//   }
// }]



output keyVaultUri string = keyVault.properties.vaultUri
