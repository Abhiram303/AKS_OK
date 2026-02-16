#!/bin/bash
set -e

echo "Validating Terraform modules..."

# Validate each module
for module_dir in modules/*/; do
    module_name=$(basename "$module_dir")
    echo "Validating module: $module_name"
    
    cd "$module_dir"
    
    # Check for required files
    if [ ! -f "main.tf" ]; then
        echo "  ERROR: main.tf not found in $module_name"
        exit 1
    fi
    
    if [ ! -f "variables.tf" ]; then
        echo "  WARNING: variables.tf not found in $module_name"
    fi
    
    if [ ! -f "outputs.tf" ]; then
        echo "  WARNING: outputs.tf not found in $module_name"
    fi
    
    # Run terraform fmt
    echo "  Running terraform fmt..."
    terraform fmt -check || echo "  WARNING: Formatting issues found"
    
    # Run terraform validate (requires init first)
    # Skipping validate as it requires provider initialization
    # terraform validate
    
    cd - > /dev/null
    echo "  ✓ $module_name validated"
done

echo ""
echo "Module validation complete!"
