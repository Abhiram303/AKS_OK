variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28.3"
}

variable "sku_tier" {
  description = "SKU tier for AKS cluster"
  type        = string
  default     = "Standard"
}

variable "private_cluster_enabled" {
  description = "Enable private cluster"
  type        = bool
  default     = true
}

variable "automatic_channel_upgrade" {
  description = "Automatic channel upgrade"
  type        = string
  default     = "stable"
}

variable "vnet_subnet_id" {
  description = "Subnet ID for AKS nodes"
  type        = string
}

variable "default_node_pool_name" {
  description = "Name of the default node pool"
  type        = string
  default     = "default"
}

variable "default_node_pool_node_count" {
  description = "Initial node count for default node pool"
  type        = number
  default     = 3
}

variable "default_node_pool_vm_size" {
  description = "VM size for default node pool"
  type        = string
  default     = "Standard_D4ads_v5"
}

variable "default_node_pool_enable_auto_scaling" {
  description = "Enable auto-scaling for default node pool"
  type        = bool
  default     = true
}

variable "default_node_pool_min_count" {
  description = "Minimum node count for auto-scaling"
  type        = number
  default     = 3
}

variable "default_node_pool_max_count" {
  description = "Maximum node count for auto-scaling"
  type        = number
  default     = 10
}

variable "default_node_pool_max_pods" {
  description = "Maximum pods per node"
  type        = number
  default     = 110
}

variable "default_node_pool_os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 128
}

variable "default_node_pool_availability_zones" {
  description = "Availability zones for default node pool"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "dns_service_ip" {
  description = "DNS service IP address"
  type        = string
  default     = "172.16.0.10"
}

variable "service_cidr" {
  description = "Service CIDR"
  type        = string
  default     = "172.16.0.0/16"
}

variable "pod_cidr" {
  description = "Pod CIDR for CNI Overlay"
  type        = string
  default     = "10.244.0.0/16"
}

variable "outbound_type" {
  description = "Outbound type for cluster egress"
  type        = string
  default     = "loadBalancer"
}

variable "azure_rbac_enabled" {
  description = "Enable Azure RBAC for Kubernetes authorization"
  type        = bool
  default     = true
}

variable "admin_group_object_ids" {
  description = "Azure AD group object IDs for cluster admins"
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for monitoring"
  type        = string
}

variable "maintenance_window" {
  description = "Maintenance window configuration"
  type = object({
    day   = string
    hours = list(number)
  })
  default = null
}

variable "additional_node_pools" {
  description = "Additional node pools configuration"
  type = map(object({
    name                = string
    vm_size             = string
    node_count          = number
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    max_pods            = number
    os_disk_size_gb     = number
    os_type             = string
    availability_zones  = list(string)
    node_labels         = map(string)
    node_taints         = list(string)
    tags                = map(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
