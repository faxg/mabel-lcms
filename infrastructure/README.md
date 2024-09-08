# How to deploy

## Prerequisites:
- az tool installed
- Azure subscription ID with admin permissions

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