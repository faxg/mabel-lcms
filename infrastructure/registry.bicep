param prefix string


resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: toLower(replace(replace(replace('${prefix}registry', '-', ''), '_', ''), ' ', ''))
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
}

output containerRegistryName string = containerRegistry.name
output containerRegistryLoginServer string = containerRegistry.properties.loginServer
