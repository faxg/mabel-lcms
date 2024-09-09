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
export resourceGroupName='mabel-lcms-rg'

export applicationRegistrationDetails=$(az ad app create --display-name $applicationRegistrationDisplayName)
export applicationRegistrationObjectId=$(echo $applicationRegistrationDetails | jq -r '.id')
export applicationRegistrationAppId=$(echo $applicationRegistrationDetails | jq -r '.appId')


az ad app federated-credential create \
   --id $applicationRegistrationObjectId \
   --parameters "{\"name\":\"${applicationRegistrationDisplayName}\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"


export resourceGroupResourceId=$(az group create --name $resourceGroupName --location westeurope --query id --output tsv)


az ad sp create --id $applicationRegistrationObjectId
az role assignment create \
   --assignee $applicationRegistrationAppId \
   --role Contributor \
   --scope $resourceGroupResourceId

echo "Add to the GitHub > repository > settings > Secrets and variables > Actions
echo "AZURE_CLIENT_ID: $applicationRegistrationAppId"
echo "AZURE_TENANT_ID: $(az account show --query tenantId --output tsv)"
echo "AZURE_SUBSCRIPTION_ID: $(az account show --query id --output tsv)"

# AZURE_CLIENT_ID: 3f886c89-919a-4fb4-bf99-ab0d1288af4d
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