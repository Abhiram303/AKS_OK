# Quick Start Guide - Azure DevOps

Get your AKS Platform up and running in Azure with Azure DevOps in 30 minutes.

## Prerequisites (5 minutes)

1. Azure Subscription with Owner/Contributor access
2. Azure DevOps organization at https://dev.azure.com
3. Azure CLI or Azure Cloud Shell access

## Step 1: Create Azure DevOps Project (2 minutes)

```bash
# Go to https://dev.azure.com/<YOUR-ORG>
# Click: New Project
# Name: AKS-Platform
# Visibility: Private
# Click: Create
```

## Step 2: Create Azure Repos Repository (2 minutes)

```bash
# In project, go to Repos
# Click: Initialize repository
# Name: aks-platform
# Click: Initialize
```

## Step 3: Clone and Push Code (3 minutes)

```bash
# Clone the repo
git clone https://dev.azure.com/<YOUR-ORG>/AKS-Platform/_git/aks-platform
cd aks-platform

# Extract the zip file into this directory
# Then:
git add .
git commit -m "Initial commit"
git push origin main
```

## Step 4: Setup Terraform Backend (5 minutes)

```bash
# In Azure Cloud Shell or local terminal with Azure CLI
cd scripts
chmod +x setup-backend.sh
./setup-backend.sh

# Note the storage account name from output
# Example: sttfstate123456
```

Update backend.tf in all environments:

```bash
# Edit: environments/dev/backend.tf
# Change: storage_account_name = "sttfstate123456"

# Repeat for: stage, prod, dr
```

## Step 5: Update Your IP Addresses (5 minutes)

Edit `environments/dev/terraform.tfvars`:

```hcl
# Replace these with YOUR actual values:
vnet_address_space               = "10.0.0.0/24"   # Your VNet
aks_subnet_address_prefix        = "10.0.0.0/26"
appgw_subnet_address_prefix      = "10.0.0.64/26"
replay_vms_subnet_address_prefix = "10.0.0.128/28"
blob_subnet_address_prefix       = "10.0.0.144/28"
file_subnet_address_prefix       = "10.0.0.160/28"

# Add your Azure AD admin group
admin_group_object_ids = ["<YOUR-AZURE-AD-GROUP-ID>"]
```

Commit changes:

```bash
git add environments/dev/terraform.tfvars
git commit -m "Update network configuration"
git push origin main
```

## Step 6: Create Service Connection (3 minutes)

1. Go to: Project Settings → Service connections
2. Click: New service connection
3. Select: Azure Resource Manager
4. Choose: Service principal (automatic)
5. Subscription: Select yours
6. Name: `Azure-ServiceConnection-dev`
7. ✓ Grant access to all pipelines
8. Click: Save

## Step 7: Create and Run Pipeline (5 minutes)

1. Go to: Pipelines → Pipelines
2. Click: New pipeline
3. Select: Azure Repos Git
4. Select: aks-platform
5. Choose: Existing Azure Pipelines YAML file
6. Path: `/pipelines/azure-pipelines-dev.yml`
7. Click: Run

**Pipeline will:**
- ✓ Validate Terraform
- ✓ Create execution plan
- ✓ Deploy infrastructure (auto-approved for dev)

## Step 8: Verify Deployment (5 minutes)

```bash
# Get AKS credentials
az aks get-credentials \
  --resource-group rg-aks-platform-dev \
  --name aks-aks-platform-dev \
  --admin

# Check nodes
kubectl get nodes

# Should show 3 nodes in Ready state
```

## What Was Created?

- ✅ Resource Group: `rg-aks-platform-dev`
- ✅ Virtual Network with 5 subnets
- ✅ AKS Cluster (private, CNI Overlay, Calico)
- ✅ Azure Container Registry (private)
- ✅ Azure Key Vault (private)
- ✅ Storage Account (blob + file, private)
- ✅ Log Analytics Workspace
- ✅ Network Security Groups
- ✅ Route Tables
- ✅ All Private Endpoints

## Next Steps

1. **Deploy a test app**:
   ```bash
   kubectl create deployment nginx --image=nginx
   kubectl expose deployment nginx --port=80
   ```

2. **Install NewRelic monitoring** (see SETUP-GUIDE.md)

3. **Configure Application Gateway for Containers** (see SETUP-GUIDE.md)

4. **Create STAGE/PROD environments**:
   - Create service connections for stage/prod
   - Update IP addresses in terraform.tfvars
   - Run stage/prod pipelines

## Common Issues

**Pipeline fails on service connection**:
- Go to service connection → Manage Security → Grant permissions

**Can't access AKS**:
```bash
az aks get-credentials \
  --resource-group rg-aks-platform-dev \
  --name aks-aks-platform-dev \
  --admin \
  --overwrite-existing
```

**State lock error**:
```bash
terraform force-unlock <LOCK-ID>
```

## Resources

- Full Setup Guide: `AZURE-DEVOPS-SETUP.md`
- Detailed Guide: `SETUP-GUIDE.md`
- Azure DevOps: https://dev.azure.com
- Azure Portal: https://portal.azure.com

## Support

- Platform Team: platform-team@company.com
- Azure Support: Create ticket in Azure Portal
