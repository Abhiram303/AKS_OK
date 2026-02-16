output "diagnostic_setting_id" {
  description = "Diagnostic setting ID"
  value       = var.enable_diagnostics ? azurerm_monitor_diagnostic_setting.aks[0].id : null
}

output "action_group_id" {
  description = "Action group ID"
  value       = var.create_action_group ? azurerm_monitor_action_group.this[0].id : null
}
