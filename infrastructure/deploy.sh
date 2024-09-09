#!/bin/bash


# Check if parameters.local.json exists
if [ ! -f parameters.local.json ]; then
  echo "Error: parameters.local.json does not exist. Please create it based on parameters.example.json."
  exit 1
fi


# Deploy using the parameters
az deployment group create --resource-group mabel-lcms-rg --template-file main.bicep --parameters @parameters.local.json

#az deployment sub create --location westeurope --template-file main.bicep --parameter @parameters.local.json

# show last logs:
# az deployment operation sub list --name main --query "[?properties.provisioningState=='Failed']"