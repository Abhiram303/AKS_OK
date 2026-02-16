resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  
  public_network_access_enabled = false
  
  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}

resource "azurerm_storage_share" "file_shares" {
  for_each             = var.file_shares
  name                 = each.key
  storage_account_name = azurerm_storage_account.this.name
  quota                = each.value.quota
}

resource "azurerm_storage_container" "blob_containers" {
  for_each              = var.blob_containers
  name                  = each.key
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_private_endpoint" "blob" {
  count               = var.enable_blob_private_endpoint ? 1 : 0
  name                = "${var.name}-blob-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.blob_private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-blob-psc"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "blob-dns-zone-group"
    private_dns_zone_ids = var.blob_private_dns_zone_ids
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "file" {
  count               = var.enable_file_private_endpoint ? 1 : 0
  name                = "${var.name}-file-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.file_private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-file-psc"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }

  private_dns_zone_group {
    name                 = "file-dns-zone-group"
    private_dns_zone_ids = var.file_private_dns_zone_ids
  }

  tags = var.tags
}
