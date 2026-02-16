#!/bin/bash

# Script to validate all Terraform modules
# Run this before committing changes to Azure Repos

set -e

echo "=================================================="
echo "Validating Terraform Modules"
echo "=================================================="

# Check if we're in the project root
if [ ! -d "modules" ]; then
  echo "Error: modules directory not found"
  echo "Please run this script from the project root"
  exit 1
fi

MODULE_COUNT=0
FAILED_MODULES=()

for MODULE in modules/*/; do
  MODULE_NAME=$(basename $MODULE)
  MODULE_COUNT=$((MODULE_COUNT + 1))
  
  echo ""
  echo "[$MODULE_COUNT] Validating module: $MODULE_NAME"
  echo "---"
  
  cd $MODULE
  
  # Initialize without backend
  terraform init -backend=false > /dev/null 2>&1
  
  # Validate
  if terraform validate > /dev/null 2>&1; then
    echo "✓ $MODULE_NAME is valid"
  else
    echo "✗ $MODULE_NAME validation failed"
    FAILED_MODULES+=("$MODULE_NAME")
    terraform validate
  fi
  
  cd - > /dev/null
done

echo ""
echo "=================================================="
if [ ${#FAILED_MODULES[@]} -eq 0 ]; then
  echo "✓ All $MODULE_COUNT modules validated successfully!"
  echo "=================================================="
  exit 0
else
  echo "✗ ${#FAILED_MODULES[@]} module(s) failed validation:"
  for mod in "${FAILED_MODULES[@]}"; do
    echo "  - $mod"
  done
  echo "=================================================="
  exit 1
fi
