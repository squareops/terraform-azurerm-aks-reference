locals {
  region      = "East US"
  environment = "demo"
  name        = "skaf"
  additional_tags = {
    Owner      = "Organization_name"
    Expires    = "Never"
    Department = "Engineering"
  }
  vnet_address_space     = "20.10.0.0/16"                 # vnet address space's last two octets must be ".0.0/16" only
  subnet_count           = 2
  base_subnet            = replace(local.vnet_address_space, "/16", "/24")
  subnet_prefix          = "subnet"
  subnets                = [for i in range(local.subnet_count) : {
    name                 = "${local.subnet_prefix}-${i + 1}"
    cidr                 = replace(local.base_subnet, ".0.0", ".${i + 1}.0")
  }]
  subnet_cidrs           = [for s in local.subnets : s.cidr]
  subnet_names           = [for s in local.subnets : s.name]
  network_plugin         = "kubenet"
  k8s_version            = "1.26.3"
}

resource "azurerm_resource_group" "terraform_infra" {
  name                         = format("%s-%s-rg", local.name, local.environment)
  location                     = local.region
  tags                         = local.additional_tags
}

module "network" {
  depends_on                    = [azurerm_resource_group.terraform_infra]
  source                        = "Azure/network/azurerm"
  version                       = "3.3.0"
  resource_group_name           = azurerm_resource_group.terraform_infra.name
  vnet_name                     = format("%s-%s-network", local.name, local.environment)
  address_space                 = local.vnet_address_space
  subnet_prefixes               = local.subnet_cidrs
  subnet_names                  = local.subnet_names
  tags                          = local.additional_tags
}

module "security_groups_subnet_route_table_association" {
  depends_on                 = [module.network]
  source                     = "./modules/security-groups"
  subnet_prefixes            = local.subnet_cidrs
  subnet_names               = local.subnet_names
  resource_group_name        = azurerm_resource_group.terraform_infra.name
  resource_group_location    = azurerm_resource_group.terraform_infra.location
  vnet_subnets               = module.network.vnet_subnets
}
