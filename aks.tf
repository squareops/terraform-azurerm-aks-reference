resource "tls_private_key" "key" {
  algorithm = "RSA"
}

# There are two types of managed idetities "System assigned" & "UserAssigned". User-assigned managed identities can be used on multiple resources.
resource "azurerm_user_assigned_identity" "identity" {
  name                = "aksidentity"
  resource_group_name = azurerm_resource_group.terraform_infra.name
  location            = azurerm_resource_group.terraform_infra.location
}

module "aks_cluster" {
  depends_on = [module.vnet, azurerm_user_assigned_identity.identity]
  source     = "git::https://github.com/prajwalakhuj/terraform-azure-aks.git?ref=release/v1"

  name                              = format("%s-aks", local.name)
  environment                       = local.environment
  kubernetes_version                = local.k8s_version
  create_resource_group             = false  # Enable if you want to a create resource group for AKS cluster.
  existing_resource_group_name      = azurerm_resource_group.terraform_infra.name
  resource_group_location           = azurerm_resource_group.terraform_infra.location
  user_assigned_identity_id         = azurerm_user_assigned_identity.identity.id
  principal_id                      = azurerm_user_assigned_identity.identity.principal_id
  agents_count                      = "1" # per node pool
  agents_size                       = ["Standard_B2s", "Standard_DS2_v2"]  # node pool vm sizes
  network_plugin                    = local.network_plugin
  net_profile_dns_service_ip        = "192.168.0.10" # IP address within the Kubernetes service address range that will be used by cluster service discovery. Don't use the first IP address in your address range. The first address in your subnet range is used for the kubernetes.default.svc.cluster.local address.
  net_profile_pod_cidr              = "10.244.0.0/16" # For aks pods cidr, when choosen "azure" network plugin these value will be passed as null.
  net_profile_docker_bridge_cidr    = "172.17.0.1/16" # It's required to select a CIDR for the Docker bridge network address because otherwise Docker will pick a subnet automatically, which could conflict with other CIDRs. You must pick an address space that doesn't collide with the rest of the CIDRs on your networks, including the cluster's service CIDR and pod CIDR. Default of 172.17.0.1/16.
  net_profile_service_cidr          = "192.168.0.0/16" # This range shouldn't be used by any network element on or connected to this virtual network. Service address CIDR must be smaller than /12. You can reuse this range across different AKS clusters.
  agents_pool_name                  = [format("%sinfra", local.name), format("%sapp", local.name)]
  os_disk_size_gb                   = "30"
  enable_auto_scaling               = "true"
  agents_min_count                  = "1"
  agents_max_count                  = "3"
  enable_node_public_ip             = "false" # If we want to create public nodes set this value "true"
  agents_availability_zones         = ["1", "2", "3"] # Does not applies to all regions please verify the availablity zones for the respective region.
  rbac_enabled                      = "true"
  oidc_issuer                       = "true"
  private_cluster_enabled           = "false"  # AKS Cluster endpoint access, Disable for public access
  sku_tier                          = "Free"
  subnet_id                         = module.vnet.private_subnets
  admin_username                    = "azureuser"  # node pool username
  public_ssh_key                    = tls_private_key.key.public_key_openssh
  agents_type                       = "VirtualMachineScaleSets"  # Creates an Agent Pool backed by a Virtual Machine Scale Set.
  net_profile_outbound_type         = "loadBalancer"   # The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer.
  log_analytics_workspace_sku       = "PerGB2018" # refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing
  enable_log_analytics_solution     = "true" # Log analytics solutions are typically software solutions with data visualization and insights tools.
  enable_control_plane_logs_scrape  = "true" # Scrapes logs of the aks control plane
  control_plane_monitor_name        = format("%s-%s-aks-control-plane-logs-monitor", local.name, local.environment) # Control plane logs monitoring such as "kube-apiserver", "cloud-controller-manager", "kube-scheduler"
  additional_tags                   = local.additional_tags
  node_labels_app                   = { App-Services = "true" }
  node_labels_infra                 = { Infra-Services = "true" }
}

module "aks_bootstrap" {
  depends_on = [module.vnet, module.aks_cluster ]
  source     = "git::https://github.com/anoushkaakhourysq/terraform-azure-aks-bootstrap.git?ref=release/v1"

  environment                                   = local.environment
  name                                          = local.name
  aks_cluster_name                              = module.aks_cluster.cluster_name
  resource_group_name                           = azurerm_resource_group.terraform_infra.name
  resource_group_location                       = azurerm_resource_group.terraform_infra.location
  single_az_sc_config                           = [{ name = "infra-service-sc", zone = "1" }]
  cert_manager_letsencrypt_email                = "prajwal.akhuj@squareops.com"
  enable_single_az_storage_class                = true
  service_monitor_crd_enabled                   = true
  enable_reloader                               = true
  enable_ingress_nginx                          = true
  enable_internal_ingress_nginx                 = false
  cert_manager_enabled                          = true
  cert_manager_install_letsencrypt_http_issuers = true
  enable_external_secrets                       = true
  enable_keda                                   = true
  enable_istio                                  = false
}