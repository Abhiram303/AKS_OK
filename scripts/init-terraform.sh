#!/bin/bash
set -e

# Script to initialize Terraform for a specific environment

if [ $# -eq 0 ]; then
    echo "Usage: $0 <environment>"
    echo "Example: $0 dev"
    exit 1
fi

ENVIRONMENT=$1
ENV_DIR="environments/$ENVIRONMENT"

if [ ! -d "$ENV_DIR" ]; then
    echo "Error: Environment directory '$ENV_DIR' does not exist"
    exit 1
fi

echo "Initializing Terraform for environment: $ENVIRONMENT"
cd $ENV_DIR

echo "Running terraform init..."
terraform init

echo "Running terraform validate..."
terraform validate

echo "Terraform initialized successfully for $ENVIRONMENT"
echo "Next steps:"
echo "  1. Review and update terraform.tfvars"
echo "  2. Run: terraform plan"
echo "  3. Run: terraform apply"
