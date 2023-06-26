terraform {
  backend "azurerm" {
    resource_group_name  = "skaf-prod-tfstate-rg"
    storage_account_name = "skafprod"
    container_name       = "tfstate-prod-container"
    key                  = "terraform-infra/aks-reference.tfstate"
  }
}