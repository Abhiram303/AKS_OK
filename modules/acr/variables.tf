variable "name" {
  description = "Name of the container registry"
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

variable "sku" {
  description = "ACR SKU"
  type        = string
  default     = "Premium"
}

variable "admin_enabled" {
  description = "Enable admin user"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs"
  type        = list(string)
}

variable "georeplications" {
  description = "Geo-replication configurations"
  type = list(object({
    location                = string
    zone_redundancy_enabled = bool
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
