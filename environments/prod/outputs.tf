output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.name
}

output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = module.aks.cluster_name
}

output "aks_cluster_id" {
  description = "AKS cluster ID"
  value       = module.aks.cluster_id
}

output "aks_cluster_fqdn" {
  description = "AKS cluster FQDN"
  value       = module.aks.cluster_fqdn
}

output "acr_name" {
  description = "ACR name"
  value       = module.acr.name
}

output "acr_login_server" {
  description = "ACR login server"
  value       = module.acr.login_server
}

output "keyvault_name" {
  description = "Key Vault name"
  value       = module.keyvault.name
}

output "keyvault_uri" {
  description = "Key Vault URI"
  value       = module.keyvault.vault_uri
}

output "storage_account_name" {
  description = "Storage account name"
  value       = module.storage.name
}
