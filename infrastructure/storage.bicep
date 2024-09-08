param prefix string
param location string


resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: '${prefix}-storage'
  kind: 'BlobStorage'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
