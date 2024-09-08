param prefix string






resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: toLower(replace(replace(replace('${prefix}storage', '-', ''), '_', ''), ' ', ''))
  kind: 'StorageV2'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
  }
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output storageAccountLocation string = storageAccount.location
output storageAccountBlobEndpoints string = storageAccount.properties.primaryEndpoints.blob
