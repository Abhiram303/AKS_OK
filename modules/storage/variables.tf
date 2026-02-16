variable "name" {
  description = "Storage account name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
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

variable "file_shares" {
  description = "File shares to create"
  type = map(object({
    quota = number
  }))
  default = {}
}

variable "blob_containers" {
  description = "Blob containers to create"
  type        = map(object({}))
  default     = {}
}

variable "enable_blob_private_endpoint" {
  description = "Enable blob private endpoint"
  type        = bool
  default     = true
}

variable "blob_private_endpoint_subnet_id" {
  description = "Subnet ID for blob private endpoint"
  type        = string
  default     = ""
}

variable "blob_private_dns_zone_ids" {
  description = "Private DNS zone IDs for blob"
  type        = list(string)
  default     = []
}

variable "enable_file_private_endpoint" {
  description = "Enable file private endpoint"
  type        = bool
  default     = true
}

variable "file_private_endpoint_subnet_id" {
  description = "Subnet ID for file private endpoint"
  type        = string
  default     = ""
}

variable "file_private_dns_zone_ids" {
  description = "Private DNS zone IDs for file"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
