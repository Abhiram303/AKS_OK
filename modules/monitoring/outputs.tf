output "action_group_id" {
  description = "Action group ID"
  value       = var.create_action_group ? azurerm_monitor_action_group.this[0].id : null
}
