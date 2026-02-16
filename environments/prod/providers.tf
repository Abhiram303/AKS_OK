provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
  
  subscription_id = "<subscription-id>"
  tenant_id       = "<tenant-id>"
}

provider "azuread" {
  tenant_id = "<tenant-id>"
}
