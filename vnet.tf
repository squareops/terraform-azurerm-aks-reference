locals {
  region      = "East US 2"
  environment = "prod"
  name        = "skaf"
  additional_tags = {
    Owner      = "Organization_name"
    Expires    = "Never"
    Department = "Engineering"
  }
  address_space          = "30.10.0.0/16"
  network_plugin         = "azure"      # You can choose "kubenet(basic)" or "azure(advanced)" refer https://learn.microsoft.com/en-us/azure/aks/concepts-network#kubenet-basic-networking 
  k8s_version            = "1.26.3"     # Kubernetes cluster version
}

resource "azurerm_resource_group" "terraform_infra" {
  name            = format("%s-%s-rg", local.name, local.environment)
  location        = local.region
  tags            = local.additional_tags
}

module "vnet" {
  depends_on                    = [azurerm_resource_group.terraform_infra]
  source                        = "./modules/vnet"
  name                          = local.name
  address_space                 = local.address_space
  environment                   = local.environment
  zones                         = 2
  create_public_subnets         = true
  create_private_subnets        = true
  create_database_subnets       = false
  create_resource_group         = false
  existing_resource_group_name  = azurerm_resource_group.terraform_infra.name
  resource_group_location       = local.region
  create_vpn                    = false
  create_nat_gateway            = true
  enable_logging                = false
  additional_tags               = local.additional_tags
}
