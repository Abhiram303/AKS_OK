#!/bin/bash

# Script to initialize Terraform for an environment
# Usage: ./init-terraform.sh <environment>
# Example: ./init-terraform.sh dev

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <environment>"
  echo "Example: $0 dev"
  echo ""
  echo "Available environments: dev, stage, prod, dr"
  exit 1
fi

ENVIRONMENT=$1
ENV_DIR="environments/$ENVIRONMENT"

if [ ! -d "$ENV_DIR" ]; then
  echo "Error: Environment directory $ENV_DIR not found"
  echo ""
  echo "Available environments:"
  ls -d environments/*/ | xargs -n 1 basename
  exit 1
fi

echo "=================================================="
echo "Initializing Terraform for: $ENVIRONMENT"
echo "=================================================="

# Check Azure login
az account show > /dev/null 2>&1 || {
  echo "Please login to Azure first:"
  echo "  az login"
  exit 1
}

# Navigate to environment directory
cd $ENV_DIR

# Initialize Terraform
echo ""
echo "Running: terraform init"
terraform init

# Validate configuration
echo ""
echo "Running: terraform validate"
terraform validate

# Format check
echo ""
echo "Running: terraform fmt -check"
terraform fmt -check || {
  echo "Warning: Terraform files not properly formatted"
  echo "Run 'terraform fmt' to fix"
}

echo ""
echo "=================================================="
echo "Terraform initialized successfully for $ENVIRONMENT!"
echo "=================================================="
echo ""
echo "Next steps:"
echo "  1. Review/update terraform.tfvars"
echo "  2. Run: terraform plan"
echo "  3. Run: terraform apply"
echo ""
