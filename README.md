# AKS Platform Infrastructure

Enterprise-grade Azure Kubernetes Service (AKS) infrastructure deployed using Terraform and Azure DevOps CI/CD.

## Architecture

### Environments
- **Dev**: South Central US
- **Stage**: South Central US  
- **Prod**: East US 2
- **DR**: South Central US

### Network Configuration (PLACEHOLDER - UPDATE WITH ACTUAL VALUES)
- **VNet CIDR**: 10.100.0.0/24 (256 IPs)
- **AKS Cluster**: 10.100.0.0/26 (64 IPs, 59 usable)
- **Application Gateway**: 10.100.0.64/26 (64 IPs, 59 usable)
- **Replay VMs**: 10.100.0.128/28 (16 IPs, 11 usable)
- **Blob Storage PE**: 10.100.0.144/28 (16 IPs, 11 usable)
- **File Storage PE**: 10.100.0.160/28 (16 IPs, 11 usable)

### Technology Stack
- **Network Plugin**: CNI Overlay
- **Network Policy**: Calico
- **Storage**: Azure Files & Blob Storage (Private Endpoints)
- **Monitoring**: NewRelic + Azure Log Analytics
- **Ingress**: Application Gateway for Containers (AGC)
- **Secrets**: Azure Key Vault
- **Disk Encryption**: Azure Default

### Compute Specifications
- **OS**: Ubuntu with container modules
- **Node Pool Sizes**: 
  - Standard_D8ads_v5 (8 CPU / 32 GB RAM)
  - Standard_D4ads_v5 (4 CPU / 16 GB RAM)

## Quick Start

### Prerequisites
1. Azure Subscription with Contributor/Owner access
2. Azure DevOps organization and project
3. Azure Repos repository
4. Terraform >= 1.5.0
5. Azure CLI >= 2.50.0

### Local Deployment
```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### Pipeline Deployment
Import pipeline YAML files into Azure DevOps and configure service connections.

## Repository Structure

```
aks-platform/
├── modules/                    # Terraform modules
├── environments/               # Environment configs (dev/stage/prod/dr)
├── global/                     # Global provider configs
├── pipelines/                  # Azure DevOps YAML pipelines
├── scripts/                    # Helper scripts
└── policies/                   # Azure policies
```

## Variables to Replace
- All IP addresses (10.100.x.x/xx)
- Subscription IDs, Tenant IDs
- Resource naming conventions
- Tags

## Post-Deployment
1. Configure kubectl access
2. Install Calico network policy
3. Deploy NewRelic integration
4. Configure AGC ingress controller
5. Validate private endpoint DNS resolution

## Support
For issues or questions, contact the platform engineering team.

**Note**: This project uses Azure Repos for version control and Azure DevOps for CI/CD.
