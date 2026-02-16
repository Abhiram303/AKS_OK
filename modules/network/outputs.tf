output "vnet_id" {
  description = "Virtual network ID"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Virtual network name"
  value       = azurerm_virtual_network.this.name
}

output "aks_subnet_id" {
  description = "AKS subnet ID"
  value       = azurerm_subnet.aks.id
}

output "aks_subnet_name" {
  description = "AKS subnet name"
  value       = azurerm_subnet.aks.name
}

output "appgw_subnet_id" {
  description = "Application Gateway subnet ID"
  value       = azurerm_subnet.appgw.id
}

output "replay_vms_subnet_id" {
  description = "Replay VMs subnet ID"
  value       = azurerm_subnet.replay_vms.id
}

output "blob_subnet_id" {
  description = "Blob storage private endpoint subnet ID"
  value       = azurerm_subnet.blob.id
}

output "file_subnet_id" {
  description = "File storage private endpoint subnet ID"
  value       = azurerm_subnet.file.id
}

output "aks_nsg_id" {
  description = "AKS NSG ID"
  value       = azurerm_network_security_group.aks.id
}

output "appgw_nsg_id" {
  description = "Application Gateway NSG ID"
  value       = azurerm_network_security_group.appgw.id
}

output "aks_route_table_id" {
  description = "AKS route table ID"
  value       = azurerm_route_table.aks.id
}
