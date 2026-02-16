output "cluster_id" {
  description = "AKS cluster ID"
  value       = azurerm_kubernetes_cluster.this.id
}

output "cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.this.name
}

output "kube_config" {
  description = "Kubernetes configuration"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "kubelet_identity_object_id" {
  description = "Kubelet identity object ID"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "cluster_identity_principal_id" {
  description = "Cluster identity principal ID"
  value       = azurerm_user_assigned_identity.aks.principal_id
}

output "cluster_fqdn" {
  description = "Cluster FQDN"
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "cluster_private_fqdn" {
  description = "Cluster private FQDN"
  value       = azurerm_kubernetes_cluster.this.private_fqdn
}

output "node_resource_group" {
  description = "Node resource group name"
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}
