resource "azurerm_container_registry" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled
  
  public_network_access_enabled = false
  network_rule_bypass_option    = "AzureServices"

  identity {
    type = "SystemAssigned"
  }

  dynamic "georeplications" {
    for_each = var.georeplications
    content {
      location = georeplications.value.location
      tags     = merge(var.tags, georeplications.value.tags)
    }
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "acr" {
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = azurerm_container_registry.this.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags
}
