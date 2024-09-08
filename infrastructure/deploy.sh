#!/bin/bash

# Default values
PREFIX=${1:-marbel-lcms}
LOCATION=${2:-westeurope}

# Deploy using the parameters
az deployment group create --resource-group ${PREFIX}-rg --template-file main.bicep --parameters prefix=${PREFIX} location=${LOCATION} @parameters.json