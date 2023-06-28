module "vnet" {
  depends_on  = [azurerm_resource_group.terraform_infra]
  source      = "git::https://github.com/anoushkaakhourysq/terraform-azure-vnet.git?ref=release/v1"

  name                          = local.name
  address_space                 = local.address_space
  environment                   = local.environment
  create_public_subnets         = true
  create_private_subnets        = true
  create_database_subnets       = false
  num_public_subnets            = "1"
  num_private_subnets           = "1"
  num_database_subnets          = "0"
  create_resource_group         = false
  existing_resource_group_name  = azurerm_resource_group.terraform_infra.name
  resource_group_location       = local.region
  create_vpn                    = false
  create_nat_gateway            = true
  enable_logging                = false
  additional_tags               = local.additional_tags
}
