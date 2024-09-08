# How to deploy

## Prerequisites:
- az tool installed
- Azure subscription ID with admin permissions

## Deploy new environment
```bash
az login
az account set --subscription <your-subscription-id>
az deployment group create --template-file main.bicep
```