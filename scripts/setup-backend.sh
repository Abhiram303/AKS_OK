#!/bin/bash

# Script to setup Terraform backend storage in Azure
# Run this script in Azure Cloud Shell or with Azure CLI

set -e

RESOURCE_GROUP="rg-terraform-state"
LOCATION="eastus2"
STORAGE_ACCOUNT="sttfstate$(date +%s | tail -c 6)"
CONTAINER_NAME="tfstate"

echo "=================================================="
echo "Terraform Backend Storage Setup"
echo "=================================================="
echo "This script will create Azure Storage for Terraform state"
echo ""
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "Storage Account: $STORAGE_ACCOUNT"
echo "Container: $CONTAINER_NAME"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

# Login check
echo "Checking Azure login status..."
az account show > /dev/null 2>&1 || {
  echo "Please login to Azure first:"
  echo "  az login"
  exit 1
}

# Create resource group
echo ""
echo "Creating resource group..."
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --tags ManagedBy=Terraform Purpose=StateStorage

# Create storage account
echo ""
echo "Creating storage account..."
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --encryption-services blob \
  --https-only true \
  --allow-blob-public-access false \
  --min-tls-version TLS1_2

# Enable versioning
echo ""
echo "Enabling blob versioning..."
az storage account blob-service-properties update \
  --account-name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --enable-versioning true

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list \
  --resource-group $RESOURCE_GROUP \
  --account-name $STORAGE_ACCOUNT \
  --query '[0].value' -o tsv)

# Create blob container
echo ""
echo "Creating blob container..."
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT \
  --account-key $ACCOUNT_KEY

echo ""
echo "=================================================="
echo "Backend storage created successfully!"
echo "=================================================="
echo ""
echo "IMPORTANT: Update backend.tf in ALL environments:"
echo ""
echo "terraform {"
echo "  backend \"azurerm\" {"
echo "    resource_group_name  = \"$RESOURCE_GROUP\""
echo "    storage_account_name = \"$STORAGE_ACCOUNT\""
echo "    container_name       = \"$CONTAINER_NAME\""
echo "    key                  = \"<environment>.terraform.tfstate\""
echo "  }"
echo "}"
echo ""
echo "Storage Account: $STORAGE_ACCOUNT"
echo ""
