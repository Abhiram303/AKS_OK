variable "name" {
  description = "Name of the storage account"
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

variable "account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
}

variable "account_kind" {
  description = "Storage account kind"
  type        = string
  default     = "StorageV2"
}

variable "blob_retention_days" {
  description = "Blob soft delete retention days"
  type        = number
  default     = 7
}

variable "container_retention_days" {
  description = "Container soft delete retention days"
  type        = number
  default     = 7
}

variable "blob_private_endpoint_subnet_id" {
  description = "Subnet ID for blob private endpoint"
  type        = string
}

variable "file_private_endpoint_subnet_id" {
  description = "Subnet ID for file private endpoint"
  type        = string
}

variable "blob_private_dns_zone_id" {
  description = "Private DNS zone ID for blob"
  type        = string
}

variable "file_private_dns_zone_id" {
  description = "Private DNS zone ID for file"
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
