resource "azurerm_user_assigned_identity" "aks" {
  name                = "${var.cluster_name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_kubernetes_cluster" "this" {
  name                      = var.cluster_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  dns_prefix                = var.dns_prefix
  kubernetes_version        = var.kubernetes_version
  sku_tier                  = var.sku_tier
  private_cluster_enabled   = var.private_cluster_enabled
  automatic_channel_upgrade = var.automatic_channel_upgrade

  default_node_pool {
    name                 = var.default_node_pool_name
    node_count           = var.default_node_pool_node_count
    vm_size              = var.default_node_pool_vm_size
    vnet_subnet_id       = var.vnet_subnet_id
    enable_auto_scaling  = var.default_node_pool_enable_auto_scaling
    min_count            = var.default_node_pool_enable_auto_scaling ? var.default_node_pool_min_count : null
    max_count            = var.default_node_pool_enable_auto_scaling ? var.default_node_pool_max_count : null
    max_pods             = var.default_node_pool_max_pods
    os_disk_size_gb      = var.default_node_pool_os_disk_size_gb
    os_disk_type         = "Managed"
    type                 = "VirtualMachineScaleSets"
    zones                = var.default_node_pool_availability_zones
    enable_node_public_ip = false
    
    upgrade_settings {
      max_surge = "33%"
    }

    tags = var.tags
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  network_profile {
    network_plugin      = "azure"
    network_policy      = "calico"
    network_mode        = "transparent"
    network_plugin_mode = "overlay"
    dns_service_ip      = var.dns_service_ip
    service_cidr        = var.service_cidr
    pod_cidr            = var.pod_cidr
    load_balancer_sku   = "standard"
    outbound_type       = var.outbound_type
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = var.azure_rbac_enabled
    admin_group_object_ids = var.admin_group_object_ids
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {
      allowed {
        day   = maintenance_window.value.day
        hours = maintenance_window.value.hours
      }
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each = var.additional_node_pools

  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  vnet_subnet_id        = var.vnet_subnet_id
  enable_auto_scaling   = each.value.enable_auto_scaling
  min_count             = each.value.enable_auto_scaling ? each.value.min_count : null
  max_count             = each.value.enable_auto_scaling ? each.value.max_count : null
  max_pods              = each.value.max_pods
  os_disk_size_gb       = each.value.os_disk_size_gb
  os_type               = each.value.os_type
  zones                 = each.value.availability_zones
  node_labels           = each.value.node_labels
  node_taints           = each.value.node_taints
  enable_node_public_ip = false

  upgrade_settings {
    max_surge = "33%"
  }

  tags = merge(var.tags, each.value.tags)

  lifecycle {
    ignore_changes = [node_count]
  }
}
