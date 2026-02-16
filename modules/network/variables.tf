variable "vnet_name" {
  description = "Name of the virtual network"
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

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
}

variable "aks_subnet_name" {
  description = "Name of the AKS subnet"
  type        = string
  default     = "snet-aks"
}

variable "aks_subnet_address_prefix" {
  description = "Address prefix for AKS subnet (/26)"
  type        = string
}

variable "appgw_subnet_name" {
  description = "Name of the Application Gateway subnet"
  type        = string
  default     = "snet-appgw"
}

variable "appgw_subnet_address_prefix" {
  description = "Address prefix for Application Gateway subnet (/26)"
  type        = string
}

variable "replay_vms_subnet_name" {
  description = "Name of the Replay VMs subnet"
  type        = string
  default     = "snet-replay-vms"
}

variable "replay_vms_subnet_address_prefix" {
  description = "Address prefix for Replay VMs subnet (/28)"
  type        = string
}

variable "blob_subnet_name" {
  description = "Name of the Blob Storage private endpoint subnet"
  type        = string
  default     = "snet-blob-pe"
}

variable "blob_subnet_address_prefix" {
  description = "Address prefix for Blob Storage PE subnet (/28)"
  type        = string
}

variable "file_subnet_name" {
  description = "Name of the File Storage private endpoint subnet"
  type        = string
  default     = "snet-file-pe"
}

variable "file_subnet_address_prefix" {
  description = "Address prefix for File Storage PE subnet (/28)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
