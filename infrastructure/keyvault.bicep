param location string
param keyVaultName string

param environmentType string
param environmentConfigurationMap object

// see: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/scenarios-secrets

// crate a service principal
// resource sp 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
//   location: location
//   name: 'sp-${keyVaultName}'
// }

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForTemplateDeployment: true
    tenantId: tenant().tenantId
    accessPolicies: [
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'MySecretName'
  properties: {
    value: 'MyVerySecretValue'
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
