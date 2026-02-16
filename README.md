# AKS Platform Infrastructure

Enterprise-grade Azure Kubernetes Service (AKS) infrastructure deployed using Terraform and Azure DevOps CI/CD.

## Architecture

### Environments
- **Dev**: South Central US
- **Stage**: South Central US  
- **Prod**: East US 2
- **DR**: South Central US

### Network Configuration (PLACEHOLDER - UPDATE WITH ACTUAL VALUES)
**VNet CIDR**: 10.100.0.0/24 (256 IPs)

**Subnet Allocation**:
- AKS Cluster: 10.100.0.0/26 (64 IPs, 59 usable)
- Application Gateway: 10.100.0.64/26 (64 IPs, 59 usable)
- Replay VMs: 10.100.0.128/28 (16 IPs, 11 usable)
- Blob Storage PE: 10.100.0.144/28 (16 IPs, 11 usable)
- File Storage PE: 10.100.0.160/28 (16 IPs, 11 usable)

### Technology Stack
- **Network Plugin**: CNI Overlay
- **Network Policy**: Calico
- **Storage**: Azure Files & Blob Storage (Private Endpoints)
- **Monitoring**: NewRelic + Azure Log Analytics
- **Ingress**: Application Gateway for Containers (AGC)
- **Secrets**: Azure Key Vault
- **Disk Encryption**: Azure Default (SSE)

### Compute Specifications
- **OS**: Ubuntu with container modules
- **VM SKUs**: 
  - Standard_D8ads_v5 (8 CPU / 32 GB RAM)
  - Standard_D4ads_v5 (4 CPU / 16 GB RAM)

## Quick Start

### Prerequisites
- Azure Subscription with Contributor/Owner access
- Azure DevOps organization and project
- Terraform >= 1.5.0
- Azure CLI >= 2.50.0
- Service Principal for authentication

### Initial Setup

1. **Create Terraform State Storage**:
```bash
cd scripts
chmod +x setup-backend.sh
./setup-backend.sh
```

2. **Update Backend Configuration**:
Edit `backend.tf` in each environment with your storage account details.

3. **Update Variables**:
Edit `terraform.tfvars` in each environment directory:
- Replace all IP addresses with your actual VNet/subnet CIDRs
- Update subscription IDs, tenant IDs
- Configure resource naming conventions
- Set appropriate tags

### Local Deployment

```bash
cd environments/dev
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

### Pipeline Deployment

1. Import pipeline YAML files into Azure DevOps
2. Create service connection to Azure subscription
3. Configure variable groups
4. Run pipeline for desired environment

## Project Structure

```
aks-platform/
├── modules/                    # Reusable Terraform modules
│   ├── resource-group/
│   ├── network/
│   ├── aks/
│   ├── acr/
│   ├── keyvault/
│   ├── log-analytics/
│   ├── role-assignments/
│   ├── storage/
│   ├── application-gateway/
│   └── monitoring/
├── environments/               # Environment-specific configurations
│   ├── dev/
│   ├── stage/
│   ├── prod/
│   └── dr/
├── global/                    # Global provider configurations
├── pipelines/                 # Azure DevOps CI/CD pipelines
├── scripts/                   # Helper scripts
└── policies/                  # Azure policies
```

## Post-Deployment Configuration

### 1. Configure kubectl Access
```bash
az aks get-credentials --resource-group <rg-name> --name <aks-name>
kubectl get nodes
```

### 2. Install Calico Network Policy
Calico is configured via AKS network policy setting.

### 3. Configure NewRelic Monitoring
Deploy NewRelic Kubernetes integration with your license key.

### 4. Configure Application Gateway for Containers
Follow AGC documentation for ingress controller setup.

### 5. Validate Private Endpoints
Ensure private DNS zones are correctly configured for:
- Azure Container Registry
- Azure Key Vault
- Storage Account (blob & file)

## Security Considerations

- All resources use private endpoints (no public access)
- Network isolation via NSGs and subnet segmentation
- Secrets managed in Azure Key Vault
- RBAC configured with least privilege
- Disk encryption enabled by default
- Azure Policy enforcement

## Maintenance

### Update AKS Version
```bash
# Check available versions
az aks get-upgrades --resource-group <rg> --name <aks-name>

# Update kubernetes_version in terraform.tfvars
# Run terraform plan and apply
```

### Scale Node Pools
Update node pool configuration in `terraform.tfvars` and apply changes.

## Variables to Replace

Search and replace across all files:
- `10.100.0.0/24` → Your actual VNet CIDR
- `10.100.0.X/XX` → Your actual subnet CIDRs  
- `<subscription-id>` → Your Azure subscription ID
- `<tenant-id>` → Your Azure AD tenant ID
- `<unique-suffix>` → Your organization suffix
- Update all resource names per your naming convention

## Troubleshooting

### State Lock Issues
```bash
# List locks
az storage blob list --account-name <state-storage> --container-name tfstate

# Break lock if needed (use with caution)
terraform force-unlock <lock-id>
```

### Network Connectivity
- Verify NSG rules allow required traffic
- Check private endpoint DNS resolution
- Validate route tables

### Authentication Failures
- Verify service principal has required permissions
- Check RBAC role assignments
- Validate Key Vault access policies

## Support

For issues or questions, contact the platform engineering team.

## License

Internal use only - Proprietary
