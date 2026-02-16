locals {
  resource_group_name   = "rg-${var.project_name}-${var.environment}"
  vnet_name             = "vnet-${var.project_name}-${var.environment}"
  aks_cluster_name      = "aks-${var.project_name}-${var.environment}"
  aks_dns_prefix        = "aks-${var.project_name}-${var.environment}"
  acr_name              = "acr${replace(var.project_name, "-", "")}${var.environment}"
  keyvault_name         = "kv-${var.project_name}-${var.environment}"
  storage_account_name  = "st${replace(var.project_name, "-", "")}${var.environment}"
  log_analytics_name    = "log-${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.project_name
    },
    var.tags
  )
}
