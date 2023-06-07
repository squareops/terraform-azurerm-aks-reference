output "resource_group_name" {
  description = "Resource Group Name"
  value       = azurerm_resource_group.terraform_infra.name
}
output "resource_group_location" {
  description = "Resource Group Name Location"
  value       = azurerm_resource_group.terraform_infra.location
}

output "virtual_network_name" {
  description = "Virtual Network Name"
  value       = module.network.vnet_name
}

output "subnet_id" {
  description = "Subnet ID"
  value       = "${module.security_groups_subnet_route_table_association.subnet_id}"
}

output "name" {
  description = "Common Name"
  value       = local.name
}

output "environment" {
  description = "Environment Name"
  value       = local.environment
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = "${module.aks_cluster.cluster_name}"
}

output "default_ng_rg_name" {
  description = "Default Node Group Resource Group Name"
  value       = "${module.aks_cluster.default_ng_rg_name}"
}