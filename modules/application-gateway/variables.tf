variable "name" {
  description = "Application Gateway name"
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

variable "create_public_ip" {
  description = "Create public IP for Application Gateway"
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
