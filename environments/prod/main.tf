terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
  }
}

# Resource Group
module "resource_group" {
  source = "../../modules/resource-group"

  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# Network
module "network" {
  source = "../../modules/network"

  vnet_name                      = local.vnet_name
  location                       = var.location
  resource_group_name            = module.resource_group.name
  vnet_address_space             = var.vnet_address_space
  aks_subnet_address_prefix      = var.aks_subnet_address_prefix
  appgw_subnet_address_prefix    = var.appgw_subnet_address_prefix
  replay_vms_subnet_address_prefix = var.replay_vms_subnet_address_prefix
  blob_subnet_address_prefix     = var.blob_subnet_address_prefix
  file_subnet_address_prefix     = var.file_subnet_address_prefix
  tags                           = local.common_tags
}

# Log Analytics
module "log_analytics" {
  source = "../../modules/log-analytics"

  name                = local.log_analytics_name
  location            = var.location
  resource_group_name = module.resource_group.name
  retention_in_days   = var.log_retention_days
  tags                = local.common_tags
}

# Container Registry
module "acr" {
  source = "../../modules/acr"

  name                        = local.acr_name
  resource_group_name         = module.resource_group.name
  location                    = var.location
  sku                         = var.acr_sku
  admin_enabled               = false
  private_endpoint_subnet_id  = module.network.blob_subnet_id
  private_dns_zone_ids        = [] # Add your private DNS zone IDs
  tags                        = local.common_tags

  depends_on = [module.network]
}

# Key Vault
module "keyvault" {
  source = "../../modules/keyvault"

  name                       = local.keyvault_name
  resource_group_name        = module.resource_group.name
  location                   = var.location
  sku_name                   = "standard"
  soft_delete_retention_days = 90
  purge_protection_enabled   = true
  enable_rbac_authorization  = true
  private_endpoint_subnet_id = module.network.blob_subnet_id
  private_dns_zone_ids       = [] # Add your private DNS zone IDs
  tags                       = local.common_tags

  depends_on = [module.network]
}

# Storage Account
module "storage" {
  source = "../../modules/storage"

  name                            = local.storage_account_name
  resource_group_name             = module.resource_group.name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  enable_blob_private_endpoint    = true
  blob_private_endpoint_subnet_id = module.network.blob_subnet_id
  blob_private_dns_zone_ids       = [] # Add your private DNS zone IDs
  enable_file_private_endpoint    = true
  file_private_endpoint_subnet_id = module.network.file_subnet_id
  file_private_dns_zone_ids       = [] # Add your private DNS zone IDs
  tags                            = local.common_tags

  file_shares = {
    "aks-storage" = {
      quota = 100
    }
  }

  blob_containers = {
    "aks-data" = {}
  }

  depends_on = [module.network]
}

# AKS Cluster
module "aks" {
  source = "../../modules/aks"

  cluster_name                          = local.aks_cluster_name
  location                              = var.location
  resource_group_name                   = module.resource_group.name
  dns_prefix                            = local.aks_dns_prefix
  kubernetes_version                    = var.kubernetes_version
  sku_tier                              = var.aks_sku_tier
  private_cluster_enabled               = var.aks_private_cluster_enabled
  automatic_channel_upgrade             = "stable"
  vnet_subnet_id                        = module.network.aks_subnet_id
  default_node_pool_name                = "default"
  default_node_pool_node_count          = var.default_node_pool_node_count
  default_node_pool_vm_size             = var.default_node_pool_vm_size
  default_node_pool_enable_auto_scaling = true
  default_node_pool_min_count           = var.default_node_pool_min_count
  default_node_pool_max_count           = var.default_node_pool_max_count
  default_node_pool_max_pods            = 110
  default_node_pool_os_disk_size_gb     = 128
  default_node_pool_availability_zones  = var.availability_zones
  dns_service_ip                        = var.dns_service_ip
  service_cidr                          = var.service_cidr
  pod_cidr                              = var.pod_cidr
  outbound_type                         = "loadBalancer"
  azure_rbac_enabled                    = true
  admin_group_object_ids                = var.admin_group_object_ids
  log_analytics_workspace_id            = module.log_analytics.id
  additional_node_pools                 = var.additional_node_pools
  tags                                  = local.common_tags

  depends_on = [module.network, module.log_analytics]
}

# Role Assignments
module "role_assignments" {
  source = "../../modules/role-assignments"

  role_assignments = {
    aks_acr_pull = {
      scope                = module.acr.id
      role_definition_name = "AcrPull"
      principal_id         = module.aks.kubelet_identity_object_id
    }
    aks_network_contributor = {
      scope                = module.resource_group.id
      role_definition_name = "Network Contributor"
      principal_id         = module.aks.cluster_identity_principal_id
    }
  }

  depends_on = [module.aks, module.acr]
}
