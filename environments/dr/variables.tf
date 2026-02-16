# General Variables
variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/stage/prod/dr)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

# Network Variables
variable "vnet_address_space" {
  description = "VNet address space"
  type        = string
}

variable "aks_subnet_address_prefix" {
  description = "AKS subnet CIDR"
  type        = string
}

variable "appgw_subnet_address_prefix" {
  description = "Application Gateway subnet CIDR"
  type        = string
}

variable "replay_vms_subnet_address_prefix" {
  description = "Replay VMs subnet CIDR"
  type        = string
}

variable "blob_subnet_address_prefix" {
  description = "Blob storage subnet CIDR"
  type        = string
}

variable "file_subnet_address_prefix" {
  description = "File storage subnet CIDR"
  type        = string
}

# AKS Variables
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28.3"
}

variable "aks_sku_tier" {
  description = "AKS SKU tier"
  type        = string
  default     = "Standard"
}

variable "default_node_pool_vm_size" {
  description = "Default node pool VM size"
  type        = string
  default     = "Standard_D4ads_v5"
}

variable "default_node_pool_node_count" {
  description = "Default node pool initial node count"
  type        = number
  default     = 3
}

variable "default_node_pool_enable_auto_scaling" {
  description = "Enable auto-scaling for default node pool"
  type        = bool
  default     = true
}

variable "default_node_pool_min_count" {
  description = "Minimum nodes in default pool"
  type        = number
  default     = 3
}

variable "default_node_pool_max_count" {
  description = "Maximum nodes in default pool"
  type        = number
  default     = 10
}

variable "admin_group_object_ids" {
  description = "Azure AD group object IDs for cluster admins"
  type        = list(string)
  default     = []
}

variable "additional_node_pools" {
  description = "Additional node pools"
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

# ACR Variables
variable "acr_sku" {
  description = "ACR SKU"
  type        = string
  default     = "Premium"
}

variable "acr_private_dns_zone_id" {
  description = "Private DNS zone ID for ACR"
  type        = string
}

# Key Vault Variables
variable "keyvault_private_dns_zone_id" {
  description = "Private DNS zone ID for Key Vault"
  type        = string
}

# Storage Variables
variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Storage replication type"
  type        = string
  default     = "LRS"
}

variable "blob_private_dns_zone_id" {
  description = "Private DNS zone ID for blob storage"
  type        = string
}

variable "file_private_dns_zone_id" {
  description = "Private DNS zone ID for file storage"
  type        = string
}

variable "file_shares" {
  description = "File shares to create"
  type = map(object({
    quota    = number
    protocol = string
  }))
  default = {}
}

# Log Analytics Variables
variable "log_analytics_retention_days" {
  description = "Log Analytics retention in days"
  type        = number
  default     = 30
}

# Application Gateway Variables
variable "create_application_gateway" {
  description = "Create Application Gateway"
  type        = bool
  default     = false
}

# Monitoring Variables
variable "create_monitoring_action_group" {
  description = "Create monitoring action group"
  type        = bool
  default     = false
}

variable "monitoring_email_receivers" {
  description = "Email receivers for monitoring alerts"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

# Tags
variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
