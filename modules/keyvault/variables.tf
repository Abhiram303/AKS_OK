variable "name" {
  description = "Key Vault name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "sku_name" {
  description = "Key Vault SKU"
  type        = string
  default     = "standard"
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention days"
  type        = number
  default     = 90
}

variable "purge_protection_enabled" {
  description = "Enable purge protection"
  type        = bool
  default     = true
}

variable "enable_rbac_authorization" {
  description = "Enable RBAC authorization"
  type        = bool
  default     = true
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
