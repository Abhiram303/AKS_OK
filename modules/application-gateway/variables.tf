variable "name" {
  description = "Name of the Application Gateway"
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

variable "subnet_id" {
  description = "Subnet ID for Application Gateway"
  type        = string
}

variable "sku_name" {
  description = "SKU name"
  type        = string
  default     = "Standard_v2"
}

variable "sku_tier" {
  description = "SKU tier"
  type        = string
  default     = "Standard_v2"
}

variable "capacity" {
  description = "Capacity (instance count)"
  type        = number
  default     = 2
}

variable "create_public_ip" {
  description = "Create public IP for Application Gateway"
  type        = bool
  default     = true
}

variable "create_application_gateway" {
  description = "Create Application Gateway resource"
  type        = bool
  default     = false
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
