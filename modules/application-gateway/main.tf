# Application Gateway for Containers will be configured post-deployment
# This is a placeholder for AGC-related Terraform resources

# Public IP for Application Gateway
resource "azurerm_public_ip" "appgw" {
  count               = var.create_public_ip ? 1 : 0
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.availability_zones
  tags                = var.tags
}

# Note: Application Gateway for Containers (AGC) is typically deployed
# via Kubernetes manifests or ARM templates after AKS is provisioned.
# Add your AGC Terraform configuration here as needed.
