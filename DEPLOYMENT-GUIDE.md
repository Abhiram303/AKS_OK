# AKS Platform Deployment Guide

## Overview
This guide provides step-by-step instructions for deploying the AKS platform infrastructure.

## Prerequisites

### Required Tools
- Azure CLI >= 2.50.0
- Terraform >= 1.5.0
- kubectl (for post-deployment)
- Azure subscription with Owner/Contributor access
- Azure DevOps organization (for pipeline deployment)

### Azure Resources Needed
- Service Principal or Managed Identity for Terraform
- Azure AD groups for AKS admin access
- Private DNS zones (or create them as part of deployment)

## Step 1: Prepare Azure Backend

```bash
# Navigate to scripts directory
cd scripts

# Run backend setup script
./setup-backend.sh

# Note the output - you'll need these values
```

Update all `backend.tf` files in each environment with the values from the script output.

## Step 2: Create Private DNS Zones

```bash
# Create resource group for DNS zones
az group create --name rg-dns-zones --location eastus2

# Create private DNS zones
az network private-dns zone create --resource-group rg-dns-zones --name privatelink.azurecr.io
az network private-dns zone create --resource-group rg-dns-zones --name privatelink.vaultcore.azure.net
az network private-dns zone create --resource-group rg-dns-zones --name privatelink.blob.core.windows.net
az network private-dns zone create --resource-group rg-dns-zones --name privatelink.file.core.windows.net

# Get the zone IDs and update terraform.tfvars files
az network private-dns zone show --resource-group rg-dns-zones --name privatelink.azurecr.io --query id -o tsv
# Repeat for other zones...
```

## Step 3: Update Configuration Files

### For Each Environment (dev/stage/prod/dr):

1. **Update `terraform.tfvars`**:
   - Replace IP addresses with your actual VNet/subnet CIDRs
   - Update Azure AD group object IDs for admin access
   - Configure private DNS zone IDs
   - Set project name and tags

2. **Update `providers.tf`**:
   - Replace `<subscription-id>` with your subscription ID
   - Replace `<tenant-id>` with your tenant ID

3. **Update `backend.tf`**:
   - Set correct storage account details from Step 1

## Step 4: Local Deployment (Testing)

```bash
# Initialize and deploy dev environment
cd environments/dev
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan

# Verify deployment
az aks list --output table
```

## Step 5: Configure Azure DevOps Pipeline Deployment

### Create Service Connection

1. Go to Azure DevOps → Project Settings → Service connections
2. Create new Azure Resource Manager service connection
3. Name it: `Azure-ServiceConnection-Dev` (repeat for stage, prod, dr)
4. Grant required permissions

### Update Pipeline Variables

1. Edit each `azure-pipelines-*.yml` file
2. Update `backendStorageAccount` with actual storage account name
3. Update service connection names if different

### Import Pipelines

1. Go to Pipelines → New Pipeline
2. Select Azure Repos Git (or your repo location)
3. Select "Existing Azure Pipelines YAML file"
4. Choose `pipelines/azure-pipelines-dev.yml`
5. Save (don't run yet)
6. Repeat for stage, prod, and dr

### Create Environments

1. Go to Pipelines → Environments
2. Create environments: `dev`, `stage`, `prod`, `dr`
3. Configure approvals for `prod` environment

## Step 6: Run Pipeline

1. Go to Pipelines
2. Select the dev pipeline
3. Click "Run pipeline"
4. Monitor the execution
5. Review Terraform plan in the logs
6. Approve the apply stage

## Step 7: Post-Deployment Configuration

### Configure kubectl Access

```bash
# Get AKS credentials
az aks get-credentials --resource-group rg-aks-platform-dev-southcentralus --name aks-aks-platform-dev

# Verify connection
kubectl get nodes
kubectl get namespaces
```

### Verify Network Policy

```bash
# Check if Calico is running
kubectl get pods -n kube-system | grep calico
```

### Configure NewRelic Monitoring

1. Install NewRelic Kubernetes integration
2. Apply with your license key
3. Verify data flow in NewRelic dashboard

### Configure Application Gateway for Containers

Follow AGC documentation to:
1. Install AGC controller
2. Configure ingress class
3. Test ingress routing

### Validate Private Endpoints

```bash
# Check private endpoint DNS resolution
nslookup <acr-name>.azurecr.io
nslookup <keyvault-name>.vault.azure.net
nslookup <storage-account>.blob.core.windows.net
```

## Step 8: Deploy Sample Application

```bash
# Create a test namespace
kubectl create namespace test-app

# Deploy nginx
kubectl create deployment nginx --image=nginx --namespace=test-app
kubectl expose deployment nginx --port=80 --type=ClusterIP --namespace=test-app

# Verify
kubectl get pods -n test-app
```

## Troubleshooting

### Common Issues

**Issue**: Terraform state lock
```bash
# List locks
az storage blob list --account-name <storage-account> --container-name tfstate

# Force unlock (use with caution)
terraform force-unlock <lock-id>
```

**Issue**: AKS cluster unreachable
- Verify private endpoint DNS resolution
- Check NSG rules
- Verify VNet peering if accessing from another VNet

**Issue**: ACR pull failures
- Verify role assignment (AcrPull)
- Check private endpoint connectivity
- Validate managed identity configuration

**Issue**: KeyVault access denied
- Check RBAC role assignments
- Verify private endpoint
- Validate Key Vault access policies

## Maintenance Tasks

### Update AKS Version

```bash
# Check available versions
az aks get-upgrades --resource-group <rg> --name <aks-name>

# Update terraform.tfvars
kubernetes_version = "1.29.0"

# Apply changes
terraform plan
terraform apply
```

### Scale Node Pools

Update `terraform.tfvars`:
```hcl
default_node_pool_max_count = 15
```

Apply changes:
```bash
terraform plan
terraform apply
```

### Add New Node Pool

Update `terraform.tfvars`:
```hcl
additional_node_pools = {
  gpu = {
    name                = "gpu"
    vm_size             = "Standard_NC6s_v3"
    node_count          = 1
    enable_auto_scaling = true
    min_count           = 0
    max_count           = 3
    # ... other settings
  }
}
```

## Security Best Practices

1. **Always use private endpoints** - Never expose services publicly
2. **Enable RBAC** - Use Azure AD integration for authentication
3. **Network policies** - Use Calico to control pod-to-pod communication
4. **Key rotation** - Rotate service principal credentials regularly
5. **Monitoring** - Enable all diagnostic settings and review logs
6. **Backup** - Configure backup for persistent volumes
7. **Updates** - Keep Kubernetes version up-to-date

## Support

For issues or questions:
- Check Terraform output logs
- Review Azure Portal for resource status
- Contact platform engineering team

## Cleanup

To destroy an environment:

```bash
cd environments/dev
terraform destroy -auto-approve
```

Or use the pipeline destroy template (requires modification).

---

**Important**: Always test changes in dev environment before promoting to production!
