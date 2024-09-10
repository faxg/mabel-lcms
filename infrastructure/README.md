# How to deploy

## Prerequisites
- az tool installed, logged via az login
- Azure tenant and subscription 
- An (empty) Azure ResourceGroup, with admin permissions


## Create Workload Identity for GitHub Action Workflows

Here's the script to create 
- create Application and Application Registration with federated credentials
- create a role assignment to the Resource Groupe (scope)

Azure build in roles:
https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles

```bash
export githubOrganizationName='faxg'
export githubRepositoryName='mabel-lcms'
export applicationRegistrationDisplayName='mabel-lcms-github-workflow'

# Create two resource groups (dev and PROD)
export resourceGroupName='mabel-lcms-rg'
export resourceGroupNamePROD='mabel-lcms-PROD-rg'
export resourceGroupResourceId=$(az group create --name $resourceGroupName --location westeurope --query id --output tsv)
export resourceGroupResourceIdPROD=$(az group create --name $resourceGroupNamePROD --location switzerlandnorth --query id --output tsv)

# Create Entra ID / Enterprise Application and Registration
#export applicationRegistrationDetails=$(az ad app create --display-name $applicationRegistrationDisplayName)
export applicationRegistrationDetails=$(az ad app list --display-name $applicationRegistrationDisplayName --query "[0].{id:id, appId:appId}")

export applicationRegistrationObjectId=$(echo $applicationRegistrationDetails | jq -r '.id')
export applicationRegistrationAppId=$(echo $applicationRegistrationDetails | jq -r '.appId')
# Create Service Principal for the Application Registration (will fail if exists)
az ad sp create --id $applicationRegistrationObjectId


# Create Federated credentials to access main branch
# and GitHub environments "Development" and "Production 
az ad app federated-credential create \
   --id $applicationRegistrationObjectId \
   --parameters "{\"name\":\"${applicationRegistrationDisplayName}\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

az ad app federated-credential create \
   --id $applicationRegistrationObjectId \
   --parameters "{\"name\":\"${applicationRegistrationDisplayName}-EnvDevelopment\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:environment:Development\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

az ad app federated-credential create \
   --id $applicationRegistrationObjectId \
   --parameters "{\"name\":\"${applicationRegistrationDisplayName}-EnvProduction\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:environment:Production\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

# Role assignment for Resource Group
az role assignment create \
   --assignee $applicationRegistrationAppId \
   --role Contributor \
   --scope $resourceGroupResourceId

# Role assignment for PROD Resource Group
az role assignment create \
   --assignee $applicationRegistrationAppId \
   --role Contributor \
   --scope $resourceGroupResourceIdPROD



echo "Add to the GitHub > repository > settings > Secrets and variables > Actions
echo "AZURE_CLIENT_ID: $applicationRegistrationAppId"
echo "AZURE_TENANT_ID: $(az account show --query tenantId --output tsv)"
echo "AZURE_SUBSCRIPTION_ID: $(az account show --query id --output tsv)"

# AZURE_CLIENT_ID: b048fa9c-8c04-4a0b-93b8-e18b8819bdc9
# AZURE_TENANT_ID: 9411802b-5f65-4dbc-8b39-8018962c3d89
# AZURE_SUBSCRIPTION_ID: b0d7ecf1-423a-4386-b51c-3a46bec51cd5
```




## Deploy new environment

## Purge soft-deleted resources
```bash
az keyvault purge --subscription {SUBSCRIPTION ID} --name {VAULT NAME}
```


## Delete resource group
```bash
az group delete --resource-group ToyWebsite --yes --no-wait
```

IMPORANT: you need to re-create the role assignment afterwards, or GH Actions will fail:
```bash
export resourceGroupResourceId=$(az group create --name $resourceGroupName --location westeurope --query id --output tsv)
az role assignment create \
   --assignee $applicationRegistrationAppId \
   --role Contributor \
   --scope $resourceGroupResourceId
```