param prefix string
param location string


resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: '${prefix}-registry'
  location: location
  sku: {
    name: 'Standard'
  }
}

output containerRegistryName string = containerRegistry.name
output containerRegistryLoginServer string = containerRegistry.properties.loginServer
