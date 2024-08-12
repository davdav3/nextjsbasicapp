variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "deployment"
}

variable "location" {
  description = "The location where resources will be deployed"
  type        = string
  default     = "westeurope"
}

variable "aks_cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
  default     = "akshomeworkcluster"
}

variable "acr_name" {
  description = "The name of the Azure Container Registry"
  type        = string
  default     = "acrhomeworktask"
}

variable "vm_size_one" {
  description = "VM Size for the AKS cluster System Node Pool"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "vm_size_two" {
  description = "VM Size for the AKS cluster User Node Pool" 
  type        = string
  default     = "Standard_D2s_v3"
}
