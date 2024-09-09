# How to deploy

## Prerequisites
- az tool installed
- Azure subscription ID with admin permissions



## Create Workload Identity for GitHub Action Workflows

Azure build in roles: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles

```bash
export githubOrganizationName='faxg'
export githubRepositoryName='mable-lcms'
export applicationRegistrationDisplayName=mable-lcms-github-workflow
export resourceGroupName='mabel-lcms-rg'

export applicationRegistrationDetails=$(az ad app create --display-name $applicationRegistrationDisplayName)
export applicationRegistrationObjectId=$(echo $applicationRegistrationDetails | jq -r '.id')
export applicationRegistrationAppId=$(echo $applicationRegistrationDetails | jq -r '.appId')


az ad app federated-credential create \
   --id $applicationRegistrationObjectId \
   --parameters "{\"name\":\"${applicationRegistrationDisplayName}\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"


export resourceGroupResourceId=$(az group create --name $resourceGroupName --location westeurope --query id --output tsv)


az ad sp create --id $applicationRegistrationAppId
az role assignment create \
   --assignee $applicationRegistrationAppId \
   --role Contributor \
   --scope $resourceGroupResourceId

echo "AZURE_CLIENT_ID: $applicationRegistrationAppId"
echo "AZURE_TENANT_ID: $(az account show --query tenantId --output tsv)"
echo "AZURE_SUBSCRIPTION_ID: $(az account show --query id --output tsv)"

# AZURE_CLIENT_ID: 3f886c89-919a-4fb4-bf99-ab0d1288af4d
# AZURE_TENANT_ID: 9411802b-5f65-4dbc-8b39-8018962c3d89
# AZURE_SUBSCRIPTION_ID: b0d7ecf1-423a-4386-b51c-3a46bec51cd5
```




## Deploy new environment
```bash
az login
# you may also change the default subscription: az account set --subscription <your-subscription-id>
az deployment sub create --location westeurope --template-file main.bicep 
az deployment sub create --location westeurope --template-file main.bicep --parameter @parameters.local.json
```

## Purge soft-deleted resources
```bash
az keyvault purge --subscription {SUBSCRIPTION ID} --name {VAULT NAME}
```