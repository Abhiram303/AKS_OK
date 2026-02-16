# AKS Platform Infrastructure - Azure DevOps Edition

This project deploys enterprise-grade AKS infrastructure using:
- **Azure Repos** for version control
- **Azure Pipelines** for CI/CD
- **Terraform** for Infrastructure as Code
- **Azure Storage** for Terraform state

## Quick Links

- 🚀 [Quick Start Guide](QUICKSTART-AZURE.md) - Get running in 30 minutes
- 📘 [Azure DevOps Setup](AZURE-DEVOPS-SETUP.md) - Complete setup guide
- 📖 [Detailed Guide](SETUP-GUIDE.md) - Full documentation
- 🏗️ [Architecture](README.md) - Technical architecture

## Repository Structure

```
aks-platform/
├── environments/         # Dev, Stage, Prod, DR configs
├── modules/             # Reusable Terraform modules
├── pipelines/           # Azure Pipelines YAML
├── scripts/             # Helper scripts
├── global/              # Global Terraform configs
└── policies/            # Azure policies
```

## Environments

| Environment | Region | VNet | Purpose |
|------------|---------|------|---------|
| Dev | South Central US | 10.100.0.0/24 | Development |
| Stage | South Central US | 10.101.0.0/24 | Staging/QA |
| Prod | East US 2 | 10.102.0.0/24 | Production |
| DR | South Central US | 10.103.0.0/24 | Disaster Recovery |

## Azure Pipelines

- `azure-pipelines-dev.yml` - Dev environment
- `azure-pipelines-stage.yml` - Stage environment
- `azure-pipelines-prod.yml` - Prod environment
- `azure-pipelines-dr.yml` - DR environment

## Getting Started

### 1. Clone Repository

```bash
git clone https://dev.azure.com/<YOUR-ORG>/AKS-Platform/_git/aks-platform
cd aks-platform
```

### 2. Setup Backend

```bash
cd scripts
./setup-backend.sh
```

### 3. Update Configuration

Edit `environments/dev/terraform.tfvars` with your actual values.

### 4. Create Service Connection

In Azure DevOps:
- Project Settings → Service connections
- Create Azure Resource Manager connection

### 5. Run Pipeline

- Pipelines → New pipeline
- Select Azure Repos
- Choose existing YAML: `/pipelines/azure-pipelines-dev.yml`
- Run

## Technology Stack

- **Kubernetes**: Azure Kubernetes Service (AKS)
- **Networking**: CNI Overlay, Calico Network Policy
- **Storage**: Azure Files, Azure Blob (Private Endpoints)
- **Registry**: Azure Container Registry (Private)
- **Secrets**: Azure Key Vault
- **Monitoring**: NewRelic, Azure Monitor
- **Ingress**: Application Gateway for Containers

## Branch Strategy

- `main` - Protected, requires PR
- `feature/*` - Feature branches
- `release/*` - Release branches

## Workflow

1. Create feature branch
2. Make changes
3. Create Pull Request
4. Get approval
5. Merge to main
6. Pipeline auto-runs

## Support

- Platform Team: platform-team@company.com
- Azure DevOps: https://dev.azure.com/<YOUR-ORG>

## License

Internal use only - Proprietary
