variable "resource_name" {
  description = "Name of the resource being monitored"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "target_resource_id" {
  description = "ID of the resource to monitor"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings"
  type        = bool
  default     = true
}

variable "log_categories" {
  description = "Log categories to enable"
  type        = list(string)
  default     = ["kube-apiserver", "kube-controller-manager", "kube-scheduler", "kube-audit", "cluster-autoscaler"]
}

variable "metric_categories" {
  description = "Metric categories to enable"
  type        = list(string)
  default     = ["AllMetrics"]
}

variable "create_action_group" {
  description = "Create action group for alerts"
  type        = bool
  default     = false
}

variable "action_group_name" {
  description = "Action group name"
  type        = string
  default     = "aks-alerts"
}

variable "action_group_short_name" {
  description = "Action group short name"
  type        = string
  default     = "aksalerts"
}

variable "email_receivers" {
  description = "Email receivers for alerts"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
