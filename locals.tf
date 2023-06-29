locals {
  region      = "East US"
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
