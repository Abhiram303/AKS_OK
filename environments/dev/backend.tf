terraform {
  backend "azurerm" {
    resource_group_name  = "<terraform-state-rg>"
    storage_account_name = "<terraform-state-storage-account>"
    container_name       = "tfstate"
    key                  = "dev/terraform.tfstate"
  }
}
