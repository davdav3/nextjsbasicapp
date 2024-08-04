variable "resource_group_name" {
  description = "The name of the resource group"
  default     = "myResourceGroup"
}

variable "location" {
  description = "The Azure location for deploying resources"
  default     = "eastus"
}

variable "aks_cluster_name" {
  description = "The name of the AKS cluster"
  default     = "myAKSCluster"
}

variable "acr_name" {
  description = "The name of the Azure Container Registry"
  default     = "myACR"
}

variable "dns_prefix" {
  description = "The DNS prefix for the AKS cluster"
  default     = "myakscluster"
}

variable "vnet_subnet_id" {
  description = "The subnet ID for the private network"
}
