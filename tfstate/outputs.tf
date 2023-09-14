output "terraform_state_resource_group_name" {
  value = module.backend.terraform_state_resource_group_name
  description = "Resource group name of the tfstate"
}

output "terraform_state_storage_account" {
  value = module.backend.terraform_state_storage_account
  description = "Storage account name of the tfstate"
}

output "terraform_state_storage_container_name" {
  value = module.backend.terraform_state_storage_container_name
   description = "Storage container name of the tfstate"
}
