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
    enableRbacAuthorization: true
    tenantId: tenant().tenantId
    accessPolicies: [
      {
        objectId: 'e5ba7730-e35c-4d20-85f0-5e1fd274fabd' // My User Object ID (MicrosoftAccount)
        tenantId: tenant().tenantId
        permissions: {
          keys: ['all']
          secrets: ['all']
        }
      }
      // {
      //   objectId: 'b74e3b92-6566-4336-a131-aeffef931168' // Workflow runner GitHub Actions 'mabel-lcms-github-workflow'
      //   tenantId: tenant().tenantId
      //   permissions: {
      //     keys: ['all']
      //     secrets: ['all']
      //   }
      // }
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
