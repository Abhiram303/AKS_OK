# Azure DevOps Complete Setup Guide

This guide covers the complete setup of the AKS Platform infrastructure using Azure DevOps, Azure Repos, and Azure Pipelines.

## Prerequisites Checklist

- [ ] Azure Subscription (Contributor or Owner role)
- [ ] Azure DevOps Organization
- [ ] Azure DevOps Project created
- [ ] Azure CLI installed locally (or use Azure Cloud Shell)
- [ ] Terraform installed locally (or use Azure Cloud Shell)
- [ ] Appropriate permissions in Azure AD

## Part 1: Azure DevOps Project Setup

### 1.1 Create Azure DevOps Project

1. Go to https://dev.azure.com/
2. Click on your organization
3. Click **New Project**
4. Enter project details:
   - Name: `AKS-Platform`
   - Visibility: Private
   - Version control: Git
5. Click **Create**

### 1.2 Create Azure Repos Repository

1. In your new project, go to **Repos**
2. If prompted to initialize the repo, click **Initialize**
3. Repository name: `aks-platform`
4. Add a README: Check this option
5. Click **Initialize**

### 1.3 Set Branch Policies (Important for Production)

1. Go to **Repos** → **Branches**
2. Find the `main` branch
3. Click the three dots → **Branch policies**
4. Configure:
   - **Require a minimum number of reviewers**: 1 (or more for prod)
   - **Check for linked work items**: Optional
   - **Check for comment resolution**: Recommended
   - **Limit merge types**: Squash merge only (recommended)
5. Click **Save changes**

## Part 2: Local Setup and Push Code

### 2.1 Clone the Repository

Open terminal or Azure Cloud Shell:

```bash
# Clone the repository
git clone https://dev.azure.com/<YOUR-ORG>/<YOUR-PROJECT>/_git/aks-platform
cd aks-platform

# Verify remote
git remote -v
```

### 2.2 Extract and Add Project Files

1. Extract the `aks-platform-complete.zip` file
2. Copy all contents into the cloned repository
3. Verify structure:

```bash
ls -la
# You should see: modules/, environments/, pipelines/, scripts/, global/, policies/
```

### 2.3 Update Configuration Files

**Update Terraform Backend:**

```bash
# First, create the backend storage
cd scripts
./setup-backend.sh

# Note the storage account name from the output
# Example: sttfstate123456
```

**Update backend.tf in ALL environments:**

```bash
# Dev
vi environments/dev/backend.tf
# Update: storage_account_name = "sttfstate<YOUR-SUFFIX>"

# Stage
vi environments/stage/backend.tf
# Update: storage_account_name = "sttfstate<YOUR-SUFFIX>"

# Prod
vi environments/prod/backend.tf
# Update: storage_account_name = "sttfstate<YOUR-SUFFIX>"

# DR
vi environments/dr/backend.tf
# Update: storage_account_name = "sttfstate<YOUR-SUFFIX>"
```

**Update IP Addresses in terraform.tfvars:**

```bash
# Dev environment
vi environments/dev/terraform.tfvars
# Replace:
# - vnet_address_space with YOUR actual VNet CIDR
# - All subnet CIDRs
# - admin_group_object_ids with YOUR Azure AD group IDs

# Repeat for stage, prod, dr
```

### 2.4 Commit and Push to Azure Repos

```bash
# Add all files
git add .

# Commit
git commit -m "Initial commit: AKS Platform Infrastructure"

# Push to Azure Repos
git push origin main
```

## Part 3: Azure DevOps Service Connections

### 3.1 Create Service Principal (Automated Method)

1. Go to **Project Settings** (bottom left)
2. Under **Pipelines**, click **Service connections**
3. Click **New service connection**
4. Select **Azure Resource Manager** → **Next**
5. Select **Service principal (automatic)**
6. Configure:
   - Scope level: **Subscription**
   - Subscription: Select your subscription
   - Resource group: Leave empty (subscription-level access)
   - Service connection name: `Azure-ServiceConnection-dev`
   - Grant access permission to all pipelines: Check this
7. Click **Save**

### 3.2 Create Service Connections for All Environments

Repeat the above for:
- `Azure-ServiceConnection-stage`
- `Azure-ServiceConnection-prod`
- `Azure-ServiceConnection-dr`

**Alternative**: Use the same service connection for all environments if permissions allow.

### 3.3 Grant Required RBAC Permissions

Each service principal needs these roles on your subscription:
- **Contributor** (to create/manage resources)
- **User Access Administrator** (to assign roles to AKS managed identity)

```bash
# Get service principal object ID
az ad sp list --display-name "Azure-ServiceConnection-dev" --query "[0].id" -o tsv

# Assign roles
SP_ID="<service-principal-object-id>"
SUBSCRIPTION_ID="<your-subscription-id>"

az role assignment create \
  --assignee $SP_ID \
  --role "Contributor" \
  --scope /subscriptions/$SUBSCRIPTION_ID

az role assignment create \
  --assignee $SP_ID \
  --role "User Access Administrator" \
  --scope /subscriptions/$SUBSCRIPTION_ID
```

## Part 4: Azure Pipelines Setup

### 4.1 Create DEV Pipeline

1. Go to **Pipelines** → **Pipelines**
2. Click **New pipeline** (or **Create Pipeline**)
3. Select **Azure Repos Git**
4. Select repository: `aks-platform`
5. Select **Existing Azure Pipelines YAML file**
6. Branch: `main`
7. Path: `/pipelines/azure-pipelines-dev.yml`
8. Click **Continue**
9. Review the YAML
10. Click **Run** (or **Save** if not ready to run)

### 4.2 Create STAGE Pipeline

Repeat above with path: `/pipelines/azure-pipelines-stage.yml`

### 4.3 Create PROD Pipeline

Repeat above with path: `/pipelines/azure-pipelines-prod.yml`

**Important for PROD**: Add manual approval gate
1. Go to **Environments** (under Pipelines)
2. Click **New environment**
3. Name: `prod`
4. Click **Create**
5. Click the three dots → **Approvals and checks**
6. Add **Approvals**
7. Add required approvers
8. Save

### 4.4 Create DR Pipeline

Repeat above with path: `/pipelines/azure-pipelines-dr.yml`

### 4.5 Configure Pipeline Variables (Optional)

For each pipeline:
1. Edit the pipeline
2. Click **Variables** → **New variable**
3. Add variables as needed:
   - `TF_VERSION`: 1.5.7
   - Custom tags, etc.

## Part 5: Run Your First Deployment

### 5.1 Test DEV Pipeline

1. Go to **Pipelines** → **Pipelines**
2. Select the `aks-platform-dev` pipeline
3. Click **Run pipeline**
4. Select branch: `main`
5. Click **Run**

**Pipeline will execute:**
- Stage 1: Validate (terraform validate)
- Stage 2: Plan (terraform plan)
- Stage 3: Apply (terraform apply) - auto-runs for dev

### 5.2 Monitor Pipeline Execution

1. Click on the running pipeline
2. View each stage
3. Click on jobs to see detailed logs
4. Review Terraform plan output before apply

### 5.3 Verify Infrastructure Creation

After successful pipeline run:

```bash
# Login to Azure
az login

# Get AKS credentials
az aks get-credentials \
  --resource-group rg-aks-platform-dev \
  --name aks-aks-platform-dev \
  --admin

# Verify cluster
kubectl get nodes

# Check pods
kubectl get pods --all-namespaces
```

## Part 6: Azure Repos Workflow

### 6.1 Feature Branch Workflow

```bash
# Create feature branch
git checkout -b feature/add-newrelic-monitoring

# Make changes
vi environments/dev/terraform.tfvars

# Commit changes
git add .
git commit -m "Add NewRelic monitoring configuration"

# Push to Azure Repos
git push origin feature/add-newrelic-monitoring
```

### 6.2 Create Pull Request

1. Go to **Repos** → **Pull requests**
2. Click **New pull request**
3. Source: `feature/add-newrelic-monitoring`
4. Target: `main`
5. Add title and description
6. Add reviewers
7. Click **Create**

### 6.3 Review and Merge

1. Reviewers review code
2. Address feedback
3. After approval, click **Complete**
4. Select merge type: **Squash commit**
5. Click **Complete merge**

### 6.4 Automatic Pipeline Trigger

- Main pipeline will trigger automatically on merge
- Monitor in **Pipelines** view

## Part 7: Environment Promotion

### 7.1 DEV to STAGE Promotion

1. Test thoroughly in DEV
2. Update STAGE terraform.tfvars if needed
3. Manually trigger STAGE pipeline
4. Monitor deployment

### 7.2 STAGE to PROD Promotion

1. Validate in STAGE
2. Create release branch (optional):
   ```bash
   git checkout -b release/v1.0.0
   git push origin release/v1.0.0
   ```
3. Trigger PROD pipeline
4. Approve manual gate
5. Monitor production deployment

## Part 8: Post-Deployment Configuration

### 8.1 Configure kubectl Access for Team

```bash
# Create Azure AD group for AKS admins
az ad group create \
  --display-name "AKS-Platform-Admins" \
  --mail-nickname "aks-platform-admins"

# Get group object ID
GROUP_ID=$(az ad group show \
  --group "AKS-Platform-Admins" \
  --query id -o tsv)

# Update terraform.tfvars
admin_group_object_ids = ["$GROUP_ID"]

# Re-run pipeline to apply
```

### 8.2 Install NewRelic

See SETUP-GUIDE.md Section 9.3

### 8.3 Configure Application Gateway for Containers

See SETUP-GUIDE.md Section 9.4

## Part 9: Monitoring and Maintenance

### 9.1 View Pipeline History

1. Go to **Pipelines** → **Pipelines**
2. Select pipeline
3. View **Runs** tab
4. Click on any run to see details

### 9.2 View Terraform State

State is stored in Azure Storage:

```bash
# List state files
az storage blob list \
  --account-name sttfstate<YOUR-SUFFIX> \
  --container-name tfstate \
  --auth-mode login

# Download state (for review only, don't modify)
az storage blob download \
  --account-name sttfstate<YOUR-SUFFIX> \
  --container-name tfstate \
  --name dev.terraform.tfstate \
  --file dev.tfstate \
  --auth-mode login
```

### 9.3 View Resource Groups

```bash
# List all resource groups
az group list --output table | grep aks-platform
```

## Troubleshooting

### Issue: Service Connection Authorization Failed

**Solution**:
1. Go to service connection
2. Click **Manage Security**
3. Grant pipeline permissions
4. Re-run pipeline

### Issue: Terraform State Lock

**Solution**:
```bash
# Force unlock (use with caution)
cd environments/dev
terraform force-unlock <LOCK-ID>
```

### Issue: Pipeline Fails on Private Endpoint

**Solution**:
- Ensure private DNS zones exist
- Check VNet links
- Verify subnet configurations

### Issue: Cannot Access AKS

**Solution**:
```bash
# Re-fetch credentials
az aks get-credentials \
  --resource-group rg-aks-platform-dev \
  --name aks-aks-platform-dev \
  --admin \
  --overwrite-existing
```

## Security Checklist

- [ ] Service principals have least-privilege access
- [ ] Branch policies enabled on main
- [ ] Pull requests require approval
- [ ] Secrets stored in Azure Key Vault (not in tfvars)
- [ ] .tfvars files added to .gitignore
- [ ] Manual approval gates on PROD
- [ ] RBAC configured on AKS
- [ ] Network policies enabled (Calico)
- [ ] Private endpoints configured
- [ ] Audit logging enabled

## Next Steps

1. ✅ Complete initial deployment
2. ✅ Configure monitoring (NewRelic)
3. ✅ Deploy sample application
4. ✅ Configure AGC ingress
5. ✅ Set up backup strategy
6. ✅ Document runbooks
7. ✅ Train team on Azure DevOps workflow
8. ✅ Plan DR drills

## Support

- Azure DevOps: https://dev.azure.com/<YOUR-ORG>
- Azure Portal: https://portal.azure.com
- Internal Docs: [Link to your internal wiki]
- Platform Team: platform-team@company.com
