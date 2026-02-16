locals {
  environment = var.environment
  location    = var.location
  
  # Naming convention
  resource_group_name   = "rg-${var.project_name}-${var.environment}-${var.location}"
  vnet_name             = "vnet-${var.project_name}-${var.environment}"
  aks_subnet_name       = "snet-aks-${var.environment}"
  appgw_subnet_name     = "snet-appgw-${var.environment}"
  replay_vms_subnet_name = "snet-replay-${var.environment}"
  blob_subnet_name      = "snet-blob-pe-${var.environment}"
  file_subnet_name      = "snet-file-pe-${var.environment}"
  aks_cluster_name      = "aks-${var.project_name}-${var.environment}"
  aks_dns_prefix        = "aks-${var.project_name}-${var.environment}"
  acr_name              = "acr${var.project_name}${var.environment}"
  keyvault_name         = "kv-${var.project_name}-${var.environment}"
  storage_account_name  = "st${var.project_name}${var.environment}"
  log_analytics_name    = "log-${var.project_name}-${var.environment}"
  appgw_name            = "agw-${var.project_name}-${var.environment}"
  
  # Tags
  tags = merge(
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Location    = var.location
    },
    var.tags
  )
}
