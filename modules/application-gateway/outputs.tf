output "id" {
  description = "Application Gateway ID"
  value       = var.create_application_gateway ? azurerm_application_gateway.this[0].id : null
}

output "name" {
  description = "Application Gateway name"
  value       = var.name
}

output "public_ip_address" {
  description = "Public IP address"
  value       = var.create_public_ip ? azurerm_public_ip.appgw[0].ip_address : null
}
