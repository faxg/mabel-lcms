@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The type of environment. This must be "devlopment" or "production".')
@allowed([
  'development'
  'production'
])
param environmentType string = 'development'

@description('A unique suffix to add to resource names that need to be globally unique.')
@maxLength(18)
param resourceNameSuffix string = '${take(toLower(uniqueString(resourceGroup().id, environmentType)), 7)}${environmentType}'

var appServiceAppName = 'mabel-app-${resourceNameSuffix}'
var appServicePlanName = 'mabel-app-plan-${resourceNameSuffix}'
var storageAccountName = toLower('mabel${resourceNameSuffix}')

// Define the SKUs for each component based on the environment type.
var environmentConfigurationMap = {
 /**
  * config map for a "devlopment" environment.
  */
  development: {
    appServiceApp: {
      alwaysOn: false
    }
    appServicePlan: {
      sku: {
        name: 'F1'
        capacity: 1
      }
    }
    storageAccount: {
      sku: {
        name: 'Standard_LRS'
      }
    }
  }
 /**
  * config map for a "production" environment.
  */
  production: {
    appServiceApp: {
      alwaysOn: true
    }

    appServicePlan: {
      sku: {
        name: 'S1'
        capacity: 1
      }
    }
    storageAccount: {
      sku: {
        name: 'Standard_ZRS'
      }
    }
  }
}

var MabelStorageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: environmentConfigurationMap[environmentType].appServicePlan.sku
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: environmentConfigurationMap[environmentType].appServiceApp.alwaysOn
      appSettings: [
        {
          name: 'MabelStorageAccountConnectionString'
          value: MabelStorageAccountConnectionString
        }
      ]
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: environmentConfigurationMap[environmentType].storageAccount.sku
}
