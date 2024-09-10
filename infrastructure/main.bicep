@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The type of environment. This must be "devlopment" or "production".')
@allowed([
  'development'
  'production'
])
param environmentType string

@description('A unique suffix to add to resource names that need to be globally unique.')
@maxLength(18)
param resourceNameSuffix string = '${take(toLower(uniqueString(resourceGroup().id, environmentType)), 7)}${environmentType}'

@description('An external API endpoint, potentially different per environment')
param externalApiUrl string

@description('Postgres admin user')
param databaseAdminLogin string = 'mabeladmin'
@description('Postgres admin password')
@secure()
param databaseAdminPassword string

// var appServiceAppName = 'mabel-app-${resourceNameSuffix}'
// var appServicePlanName = 'mabel-app-plan-${resourceNameSuffix}'

var storageAccountName = toLower('mabel${resourceNameSuffix}')
var databaseName = 'mabel-db-${resourceNameSuffix}'

/*****
*** Define the SKUs for each component based on the environment type.
*** 
***
***
******/
var environmentConfigurationMap = {
  /**
  * config map for a "devlopment" environment.
  */
  development: {
    externalApiUrl: externalApiUrl

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

    database: {
      sku: {
        name: 'Standard_B1ms'
        tier: 'Burstable'
      }
    }
  }

  /**
  * config map for a "production" environment.
  */
  production: {
    externalApiUrl: externalApiUrl

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
    database: {
      sku: {
        name: 'Standard_B1ms'
        tier: 'Burstable'
      }
    }
  }
}

// Connection string for the Storage account

// output appServiceAppName string = appServiceAppName
// output appServicePlanName string = appServicePlanName

// resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
//   name: appServicePlanName
//   location: location
//   sku: environmentConfigurationMap[environmentType].appServicePlan.sku
// }

// resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
//   name: appServiceAppName
//   location: location
//   properties: {
//     serverFarmId: appServicePlan.id
//     httpsOnly: true
//     siteConfig: {
//       alwaysOn: environmentConfigurationMap[environmentType].appServiceApp.alwaysOn
//       appSettings: [
//         {
//           name: 'MabelStorageAccountConnectionString'
//           value: MabelStorageAccountConnectionString
//         }
//         {
//           name: 'externalApiUrl'
//           value: environmentConfigurationMap[environmentType].externalApiUrl
//         }
//       ]
//     }
//   }
// }

// resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2023-12-01-preview' = {
//   name: 'mabel-postgres-${resourceNameSuffix}'
//   location: location

//   sku: {
//     name: 'Standard_B1ms'
//     tier: 'Burstable'
//   }
//   properties: {
//     version: '15'
//     administratorLogin: 'mabeladmin'
//     administratorLoginPassword: 'Password1234!'
//     network: {
//       publicNetworkAccess: 'Enabled'
//     }
//     //availabilityZone: '1'
//     backup: {
//       backupRetentionDays: 7
//       geoRedundantBackup: 'Disabled'
//     }
//     highAvailability: {
//       mode: 'Disabled'
//     }
//   }
// }

// resource database 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2023-12-01-preview' = {
//   name: 'payloadcms'
//   parent: postgresServer

//   properties: {
//     charset: 'UTF8'
//     collation: 'en_US.utf8'
//   }
// }

module storage './storage.bicep' = {
  name: 'deploy-storage'
  params: {
    location: location
    environmentType: environmentType
    storageAccountName: storageAccountName
    environmentConfigurationMap: environmentConfigurationMap
  }
}

module database './database.bicep' = {
  name: 'deploy-database'
  params: {
    location: location
    environmentType: environmentType
    databaseName: databaseName
    databaseAdminLogin: databaseAdminLogin
    databaseAdminPassword: databaseAdminPassword
    environmentConfigurationMap: environmentConfigurationMap
  }
}

// module kv './keyvault.bicep' = {

// } 

// module app './app.bicep' = {

// } 
