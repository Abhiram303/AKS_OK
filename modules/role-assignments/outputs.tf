output "role_assignment_ids" {
  description = "Role assignment IDs"
  value       = { for k, v in azurerm_role_assignment.this : k => v.id }
}
