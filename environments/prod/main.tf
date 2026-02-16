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
  tags     = local.tags
}

# Networking
module "network" {
  source = "../../modules/network"

  vnet_name                     = local.vnet_name
  location                      = var.location
  resource_group_name           = module.resource_group.name
  vnet_address_space            = var.vnet_address_space
  aks_subnet_name               = local.aks_subnet_name
  aks_subnet_address_prefix     = var.aks_subnet_address_prefix
  appgw_subnet_name             = local.appgw_subnet_name
  appgw_subnet_address_prefix   = var.appgw_subnet_address_prefix
  replay_vms_subnet_name        = local.replay_vms_subnet_name
  replay_vms_subnet_address_prefix = var.replay_vms_subnet_address_prefix
  blob_subnet_name              = local.blob_subnet_name
  blob_subnet_address_prefix    = var.blob_subnet_address_prefix
  file_subnet_name              = local.file_subnet_name
  file_subnet_address_prefix    = var.file_subnet_address_prefix
  tags                          = local.tags

  depends_on = [module.resource_group]
}

# Log Analytics
module "log_analytics" {
  source = "../../modules/log-analytics"

  name                = local.log_analytics_name
  location            = var.location
  resource_group_name = module.resource_group.name
  retention_in_days   = var.log_analytics_retention_days
  tags                = local.tags

  depends_on = [module.resource_group]
}

# Container Registry
module "acr" {
  source = "../../modules/acr"

  name                         = local.acr_name
  location                     = var.location
  resource_group_name          = module.resource_group.name
  sku                          = var.acr_sku
  private_endpoint_subnet_id   = module.network.blob_subnet_id
  private_dns_zone_id          = var.acr_private_dns_zone_id
  tags                         = local.tags

  depends_on = [module.network]
}

# Key Vault
module "keyvault" {
  source = "../../modules/keyvault"

  name                       = local.keyvault_name
  location                   = var.location
  resource_group_name        = module.resource_group.name
  private_endpoint_subnet_id = module.network.blob_subnet_id
  private_dns_zone_id        = var.keyvault_private_dns_zone_id
  tags                       = local.tags

  depends_on = [module.network]
}

# Storage Account
module "storage" {
  source = "../../modules/storage"

  name                              = local.storage_account_name
  location                          = var.location
  resource_group_name               = module.resource_group.name
  account_tier                      = var.storage_account_tier
  account_replication_type          = var.storage_replication_type
  blob_private_endpoint_subnet_id   = module.network.blob_subnet_id
  file_private_endpoint_subnet_id   = module.network.file_subnet_id
  blob_private_dns_zone_id          = var.blob_private_dns_zone_id
  file_private_dns_zone_id          = var.file_private_dns_zone_id
  file_shares                       = var.file_shares
  tags                              = local.tags

  depends_on = [module.network]
}

# AKS Cluster
module "aks" {
  source = "../../modules/aks"

  cluster_name                           = local.aks_cluster_name
  location                               = var.location
  resource_group_name                    = module.resource_group.name
  dns_prefix                             = local.aks_dns_prefix
  kubernetes_version                     = var.kubernetes_version
  sku_tier                               = var.aks_sku_tier
  vnet_subnet_id                         = module.network.aks_subnet_id
  default_node_pool_vm_size              = var.default_node_pool_vm_size
  default_node_pool_node_count           = var.default_node_pool_node_count
  default_node_pool_enable_auto_scaling  = var.default_node_pool_enable_auto_scaling
  default_node_pool_min_count            = var.default_node_pool_min_count
  default_node_pool_max_count            = var.default_node_pool_max_count
  log_analytics_workspace_id             = module.log_analytics.id
  admin_group_object_ids                 = var.admin_group_object_ids
  additional_node_pools                  = var.additional_node_pools
  tags                                   = local.tags

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

# Application Gateway (Optional - configure based on AGC requirements)
module "application_gateway" {
  source = "../../modules/application-gateway"

  name                        = local.appgw_name
  location                    = var.location
  resource_group_name         = module.resource_group.name
  subnet_id                   = module.network.appgw_subnet_id
  create_application_gateway  = var.create_application_gateway
  tags                        = local.tags

  depends_on = [module.network]
}

# Monitoring
module "monitoring" {
  source = "../../modules/monitoring"

  resource_name              = module.aks.cluster_name
  resource_group_name        = module.resource_group.name
  target_resource_id         = module.aks.cluster_id
  log_analytics_workspace_id = module.log_analytics.id
  create_action_group        = var.create_monitoring_action_group
  email_receivers            = var.monitoring_email_receivers
  tags                       = local.tags

  depends_on = [module.aks]
}
