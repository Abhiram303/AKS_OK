variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus2"
}

variable "vnet_address_space" {
  description = "VNet address space"
  type        = string
  default     = "10.100.0.0/24"
}

variable "aks_subnet_address_prefix" {
  description = "AKS subnet address prefix"
  type        = string
  default     = "10.100.0.0/26"
}

variable "appgw_subnet_address_prefix" {
  description = "Application Gateway subnet address prefix"
  type        = string
  default     = "10.100.0.64/26"
}

variable "replay_vms_subnet_address_prefix" {
  description = "Replay VMs subnet address prefix"
  type        = string
  default     = "10.100.0.128/28"
}

variable "blob_subnet_address_prefix" {
  description = "Blob storage subnet address prefix"
  type        = string
  default     = "10.100.0.144/28"
}

variable "file_subnet_address_prefix" {
  description = "File storage subnet address prefix"
  type        = string
  default     = "10.100.0.160/28"
}

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

variable "aks_private_cluster_enabled" {
  description = "Enable private AKS cluster"
  type        = bool
  default     = true
}

variable "default_node_pool_node_count" {
  description = "Default node pool initial node count"
  type        = number
  default     = 3
}

variable "default_node_pool_vm_size" {
  description = "Default node pool VM size"
  type        = string
  default     = "Standard_D4ads_v5"
}

variable "default_node_pool_min_count" {
  description = "Default node pool minimum count"
  type        = number
  default     = 3
}

variable "default_node_pool_max_count" {
  description = "Default node pool maximum count"
  type        = number
  default     = 10
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "dns_service_ip" {
  description = "DNS service IP"
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

variable "admin_group_object_ids" {
  description = "Azure AD admin group object IDs"
  type        = list(string)
  default     = []
}

variable "acr_sku" {
  description = "ACR SKU"
  type        = string
  default     = "Premium"
}

variable "log_retention_days" {
  description = "Log Analytics retention days"
  type        = number
  default     = 30
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

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "aks-platform"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
