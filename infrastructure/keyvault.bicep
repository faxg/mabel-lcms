param location string
param keyVaultName string

@secure()
param secrets object

// see: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/scenarios-secrets

var objectIds = [
  {
    id: 'e5ba7730-e35c-4d20-85f0-5e1fd274fabd' // My User Object ID (MicrosoftAccount)
    description: 'My User Object ID (MicrosoftAccount)'
  }
  {
    id: 'b74e3b92-6566-4336-a131-aeffef931168' // Workflow runner GitHub Actions 'mabel-lcms-github-workflow'
    description: 'Workflow runner GitHub Actions "mabel-lcms-github-workflow"'
  }
]

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForTemplateDeployment: true
    enableRbacAuthorization: false
    tenantId: tenant().tenantId
    accessPolicies: [
      for objectId in objectIds: {
        objectId: objectId.id
        tenantId: tenant().tenantId
        permissions: {
          keys: ['all']
          secrets: ['all']
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource secretsResource 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = [
  for secretName in objectKeys(secrets): {
    parent: kv
    name: secretName
    properties: {
      value: secrets[secretName]
    }
  }
]

// resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
//   parent: kv
//   name: 'databaseAdminLogin'
//   properties: {
//     value: 'mabelAdmin'
//   }
// }

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

output keyVaultUri string = kv.properties.vaultUri
