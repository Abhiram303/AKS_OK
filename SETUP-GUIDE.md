# AKS Platform - Setup Guide

## Prerequisites

1. **Azure Subscription** with Contributor/Owner access
2. **Azure DevOps Organization** and Project
3. **Azure Repos** repository
4. **Azure CLI** (version 2.50.0 or later)
5. **Terraform** (version 1.5.0 or later)

## Initial Setup Steps

### Step 1: Create Azure Repos Repository

1. Go to your Azure DevOps organization
2. Navigate to your project
3. Go to **Repos** → **Files**
4. Click **Initialize** or **Import repository**
5. Create a new repository named `aks-platform`

### Step 2: Clone Repository Locally

```bash
# Clone from Azure Repos
git clone https://dev.azure.com/<your-org>/<your-project>/_git/aks-platform
cd aks-platform

# Or use SSH
git clone git@ssh.dev.azure.com:v3/<your-org>/<your-project>/aks-platform
cd aks-platform
```

### Step 3: Push Project Files

```bash
# Extract the zip file contents into the cloned repository
# Then commit and push

git add .
git commit -m "Initial commit: AKS Platform infrastructure"
git push origin main
```

### Step 4: Update Configuration Files

#### 4.1 Update IP Addresses
Replace placeholder IP addresses in all `terraform.tfvars` files:

**Dev Environment:**
```bash
cd environments/dev
vi terraform.tfvars

# Update:
# - vnet_address_space = "10.100.0.0/24"  (YOUR ACTUAL VNET)
# - All subnet address prefixes
# - admin_group_object_ids = ["<YOUR-AZURE-AD-GROUP-ID>"]
```

**Stage Environment:**
```bash
cd ../stage
vi terraform.tfvars
# Update all IP addresses and configurations
```

**Prod Environment:**
```bash
cd ../prod
vi terraform.tfvars
# Update all IP addresses and configurations
```

**DR Environment:**
```bash
cd ../dr
vi terraform.tfvars
# Update all IP addresses and configurations
```

#### 4.2 Setup Terraform Backend Storage

Run the backend setup script in Azure Cloud Shell or local Azure CLI:

```bash
cd scripts
chmod +x setup-backend.sh
./setup-backend.sh
```

This creates:
- Resource Group: `rg-terraform-state`
- Storage Account: `sttfstate<unique-suffix>`
- Container: `tfstate`

**Note the storage account name** and update `backend.tf` in ALL environments:

```bash
# Update in environments/dev/backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstate<YOUR-ACTUAL-SUFFIX>"  # <-- UPDATE THIS
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}

# Repeat for stage, prod, dr
```

#### 4.3 Commit Backend Configuration

```bash
git add environments/*/backend.tf
git commit -m "Update Terraform backend configuration"
git push origin main
```

### Step 5: Configure Azure DevOps Service Connections

#### 5.1 Create Service Connections

1. Go to Azure DevOps → **Project Settings**
2. Click **Service connections** (under Pipelines)
3. Click **New service connection**
4. Select **Azure Resource Manager**
5. Choose **Service principal (automatic)**
6. Select your subscription
7. Name the connection: `Azure-ServiceConnection-dev`
8. Click **Save**

**Repeat for all environments:**
- `Azure-ServiceConnection-dev`
- `Azure-ServiceConnection-stage`
- `Azure-ServiceConnection-prod`
- `Azure-ServiceConnection-dr`

**Important**: Grant the service principals proper RBAC roles on your subscription.

### Step 6: Create Azure DevOps Pipelines

#### 6.1 Create DEV Pipeline

1. Go to **Pipelines** → **Pipelines**
2. Click **New pipeline**
3. Select **Azure Repos Git**
4. Select your repository: `aks-platform`
5. Choose **Existing Azure Pipelines YAML file**
6. Path: `/pipelines/azure-pipelines-dev.yml`
7. Click **Continue** → **Run**

#### 6.2 Create STAGE Pipeline

Repeat above steps with path: `/pipelines/azure-pipelines-stage.yml`

#### 6.3 Create PROD Pipeline

Repeat above steps with path: `/pipelines/azure-pipelines-prod.yml`

#### 6.4 Create DR Pipeline

Repeat above steps with path: `/pipelines/azure-pipelines-dr.yml`

#### 6.5 Configure Pipeline Variables (Optional)

For each pipeline, you can add variables:
1. Edit pipeline
2. Click **Variables** → **New variable**
3. Add:
   - `ARM_SUBSCRIPTION_ID` (if needed)
   - `ARM_TENANT_ID` (if needed)

### Step 7: Test Local Deployment (Optional)

Before running pipelines, test locally:

```bash
cd environments/dev

# Login to Azure
az login

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment
terraform plan -out=tfplan

# Review the plan carefully
# If everything looks good, apply
terraform apply tfplan
```

**Expected Resources Created:**
- Resource Group
- Virtual Network with 5 subnets
- Network Security Groups
- Route Tables
- AKS Cluster (private, CNI Overlay, Calico)
- Azure Container Registry (with private endpoint)
- Azure Key Vault (with private endpoint)
- Storage Account (with blob & file private endpoints)
- Log Analytics Workspace
- Role Assignments

### Step 8: Run Azure DevOps Pipeline

1. Go to **Pipelines** → **Pipelines**
2. Select `aks-platform-dev` pipeline
3. Click **Run pipeline**
4. Select branch: `main`
5. Click **Run**

**Pipeline Stages:**
1. **Validate** - Validates Terraform configuration
2. **Plan** - Creates Terraform plan
3. **Apply** - Applies infrastructure (requires approval for prod)

### Step 9: Post-Deployment Configuration

#### 9.1 Configure kubectl Access

```bash
# Get AKS credentials
az aks get-credentials \
  --resource-group rg-aks-platform-dev \
  --name aks-aks-platform-dev \
  --admin

# Verify connection
kubectl get nodes

# Expected output: 3 nodes in Ready state
```

#### 9.2 Verify Calico Installation

```bash
# Check Calico pods
kubectl get pods -n kube-system | grep calico

# Verify network policy is enabled
kubectl get networkpolicies --all-namespaces
```

#### 9.3 Configure NewRelic Monitoring

```bash
# Add NewRelic Helm repository
helm repo add newrelic https://helm-charts.newrelic.com
helm repo update

# Create namespace
kubectl create namespace newrelic

# Install NewRelic bundle
helm install newrelic-bundle newrelic/nri-bundle \
  --set global.licenseKey=<YOUR-NEWRELIC-LICENSE-KEY> \
  --set global.cluster=aks-platform-dev \
  --set infrastructure.enabled=true \
  --set prometheus.enabled=true \
  --set logging.enabled=true \
  --set ksm.enabled=true \
  --namespace newrelic

# Verify installation
kubectl get pods -n newrelic
```

#### 9.4 Configure Application Gateway for Containers (AGC)

Follow Microsoft documentation for AGC deployment:

```bash
# Install ALB Controller (example)
kubectl apply -f https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/helm/ingress-azure/crds/AzureIngressProhibitedTarget.yaml

# Configure ingress resources as per your application needs
```

#### 9.5 Configure Private DNS Zones

Ensure private DNS zones are linked to your VNet:

**Required Private DNS Zones:**
- `privatelink.azurecr.io` (Container Registry)
- `privatelink.vaultcore.azure.net` (Key Vault)
- `privatelink.blob.core.windows.net` (Blob Storage)
- `privatelink.file.core.windows.net` (File Storage)

```bash
# Verify DNS resolution (from a VM in the VNet or via Bastion)
nslookup acrakspla tformdev.azurecr.io
# Should resolve to private IP (10.100.0.144/28 range)
```

#### 9.6 Deploy Sample Application (Optional)

```bash
# Deploy a test application
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Check service
kubectl get svc nginx
```

## Azure DevOps Workflow

### Branch Strategy

**Main Branch:**
- Protected
- Requires pull request for changes
- Triggers pipelines automatically

**Feature Branches:**
```bash
git checkout -b feature/add-monitoring
# Make changes
git add .
git commit -m "Add monitoring configuration"
git push origin feature/add-monitoring
```

**Create Pull Request:**
1. Go to Azure Repos → Pull Requests
2. Create new PR: `feature/add-monitoring` → `main`
3. Add reviewers
4. Complete PR after approval

### Environment Promotion

**Dev → Stage:**
1. Merge feature to main
2. Dev pipeline runs automatically
3. After validation, manually trigger stage pipeline

**Stage → Prod:**
1. Create release branch
2. Update prod terraform.tfvars
3. Create PR to main
4. After approval, run prod pipeline (with manual approval gate)

**DR Environment:**
- Maintained in sync with prod
- Separate pipeline for DR-specific changes
- Regular failover testing

## Troubleshooting

### Common Issues

#### 1. Pipeline Fails on Terraform Init

**Error**: "Backend configuration changed"

**Solution**:
```bash
# Run locally
cd environments/dev
terraform init -reconfigure
```

#### 2. State Lock Errors

**Error**: "Error acquiring the state lock"

**Solution**:
```bash
# List locks
az storage blob list \
  --account-name sttfstate<suffix> \
  --container-name tfstate \
  --auth-mode login

# Force unlock (use with caution)
terraform force-unlock <lock-id>
```

#### 3. Service Connection Issues

**Error**: "Service connection not authorized"

**Solution**:
1. Go to Project Settings → Service connections
2. Select the connection
3. Click **Manage Security**
4. Grant pipeline permissions

#### 4. Private Endpoint DNS Not Resolving

**Error**: Cannot pull images from ACR

**Solution**:
```bash
# Verify private DNS zone exists
az network private-dns zone list \
  --resource-group rg-aks-platform-dev

# Verify VNet link
az network private-dns link vnet list \
  --resource-group rg-aks-platform-dev \
  --zone-name privatelink.azurecr.io
```

#### 5. AKS Nodes Not Ready

**Error**: Nodes stuck in NotReady state

**Solution**:
```bash
kubectl get nodes
kubectl describe node <node-name>

# Check system pods
kubectl get pods -n kube-system

# Check node logs
kubectl logs -n kube-system <pod-name>
```

## Security Best Practices

1. **Never commit** `.tfvars` files with sensitive data to Azure Repos
2. **Use Azure Key Vault** for all secrets and credentials
3. **Enable branch policies** on main branch
4. **Require pull request reviews** for all changes
5. **Enable Azure Policy** for compliance enforcement
6. **Rotate credentials** regularly
7. **Enable audit logging** for all resources
8. **Use service principals** with least privilege
9. **Enable MFA** for all Azure DevOps users
10. **Regular security scans** with Checkov, tfsec

## Maintenance Tasks

### Update AKS Version

```bash
# Check available versions
az aks get-upgrades \
  --resource-group rg-aks-platform-dev \
  --name aks-aks-platform-dev

# Update terraform.tfvars
kubernetes_version = "1.29.0"

# Commit and push
git add environments/dev/terraform.tfvars
git commit -m "Update AKS to 1.29.0"
git push origin main

# Run pipeline or apply locally
terraform plan
terraform apply
```

### Scale Node Pools

```bash
# Update terraform.tfvars
default_node_pool_min_count = 5
default_node_pool_max_count = 15

# Commit and apply via pipeline
```

### Backup Terraform State

```bash
# Azure Storage automatically handles versioning
# View state versions
az storage blob list \
  --account-name sttfstate<suffix> \
  --container-name tfstate \
  --auth-mode login
```

## Monitoring and Alerts

### Azure Monitor

- Container Insights enabled on AKS
- Log Analytics workspace collects all logs
- Create alert rules in Azure Monitor

### NewRelic Integration

- APM monitoring for applications
- Infrastructure monitoring for nodes
- Custom dashboards for business metrics

## Cost Optimization

1. **Right-size node pools** based on metrics
2. **Use autoscaling** to match demand
3. **Implement Azure Policy** for cost controls
4. **Review Azure Advisor** recommendations
5. **Use Azure Cost Management** for insights
6. **Implement tagging strategy** for cost allocation
7. **Consider Azure Spot VMs** for dev/test

## Disaster Recovery

### DR Environment Setup

- DR environment mirrors production
- Located in South Central US
- Automated failover procedures
- Regular DR drills

### Backup Strategy

- Terraform state in Azure Storage (geo-redundant)
- Kubernetes resources backed up via Velero
- Database backups to Azure Backup
- Configuration stored in Azure Repos

## Support and Escalation

- **Platform Team**: platform-team@company.com
- **Azure Support**: Open ticket via Azure Portal
- **Azure DevOps Support**: Through Azure DevOps portal
- **Emergency On-Call**: Use PagerDuty/Teams rotation

## Additional Resources

- [Azure AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Azure DevOps Documentation](https://docs.microsoft.com/en-us/azure/devops/)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Repos Git Tutorial](https://docs.microsoft.com/en-us/azure/devops/repos/git/)
- [Calico Documentation](https://docs.projectcalico.org/)
- [Application Gateway for Containers](https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/)

## Appendix

### Naming Conventions

All resources follow this pattern:
- Resource Groups: `rg-<project>-<environment>`
- VNets: `vnet-<project>-<environment>`
- AKS: `aks-<project>-<environment>`
- ACR: `acr<project><environment>` (no hyphens)
- Key Vault: `kv-<project>-<environment>`
- Storage: `st<project><environment>` (no hyphens)

### Tagging Strategy

All resources tagged with:
- `Environment`: dev/stage/prod/dr
- `ManagedBy`: Terraform
- `Project`: aks-platform
- `CostCenter`: <your-cost-center>
- `Owner`: <team-name>

### IP Address Allocation Reference

**Dev (10.100.0.0/24):**
- AKS: 10.100.0.0/26
- AppGW: 10.100.0.64/26
- Replay VMs: 10.100.0.128/28
- Blob PE: 10.100.0.144/28
- File PE: 10.100.0.160/28

**Stage (10.101.0.0/24):**
- AKS: 10.101.0.0/26
- AppGW: 10.101.0.64/26
- Replay VMs: 10.101.0.128/28
- Blob PE: 10.101.0.144/28
- File PE: 10.101.0.160/28

**Prod (10.102.0.0/24):**
- AKS: 10.102.0.0/26
- AppGW: 10.102.0.64/26
- Replay VMs: 10.102.0.128/28
- Blob PE: 10.102.0.144/28
- File PE: 10.102.0.160/28

**DR (10.103.0.0/24):**
- AKS: 10.103.0.0/26
- AppGW: 10.103.0.64/26
- Replay VMs: 10.103.0.128/28
- Blob PE: 10.103.0.144/28
- File PE: 10.103.0.160/28
