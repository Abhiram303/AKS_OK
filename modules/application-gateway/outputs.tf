output "public_ip_id" {
  description = "Public IP ID"
  value       = var.create_public_ip ? azurerm_public_ip.appgw[0].id : null
}

output "public_ip_address" {
  description = "Public IP address"
  value       = var.create_public_ip ? azurerm_public_ip.appgw[0].ip_address : null
}
