param prefix string

param containerRegistryName string
param containerImageName string

//see: https://learn.microsoft.com/en-us/azure/templates/microsoft.app/managedenvironments?pivots=deployment-language-bicep
resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: '${prefix}-containerapp-enviroment'
  location: resourceGroup().location

  properties: { //see: https://learn.microsoft.com/en-us/azure/templates/microsoft.app/managedenvironments?pivots=deployment-language-bicep#managedenvironmentproperties

  }
}

//see: https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep
resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: '${prefix}-containerapp'
  location: resourceGroup().location

  
  identity: {
    type: 'SystemAssigned'
  }
  // see: https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#containerappproperties
  properties: {
    environmentId: containerAppEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 3000
      }
      registries: [
        {
          server: '${containerRegistryName}.azurecr.io'
          identity: 'system'
        }
      ]
      // secrets: [
      //   {
      //     name: ''
      //     keyVaultUrl: ''
      //     identity: 'system'
      //   }
      // ]
    }
    template: {
      containers: [
        {
          name: '${prefix}-container'
          image: '${containerRegistryName}.azurecr.io/${containerImageName}:latest'
          resources: {
            cpu: 1
            memory: '2.0Gi'
          }
          
        }
      ]
    }
  }
}

output containerEnvironmentName string = containerAppEnvironment.name

output containerAppName string = containerApp.name
output containerAppIdentity object = containerApp.identity
