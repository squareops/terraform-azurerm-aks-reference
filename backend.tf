terraform {
  backend "azurerm" {
    resource_group_name  = "skaf-demo-tfstate-rg"
    storage_account_name = "skafdemo"
    container_name       = "tfstate-demo-container"
    key                  = "terraform-infra/aks-reference.tfstate"
  }
}