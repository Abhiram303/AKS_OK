# NewRelic monitoring will be configured via Kubernetes manifests
# This module can be extended for Azure Monitor alerts and dashboards

resource "azurerm_monitor_action_group" "this" {
  count               = var.create_action_group ? 1 : 0
  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = var.action_group_short_name

  dynamic "email_receiver" {
    for_each = var.email_receivers
    content {
      name          = email_receiver.value.name
      email_address = email_receiver.value.email_address
    }
  }

  tags = var.tags
}
