provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  role_based_access_control {
    enabled = true
  }
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"

  admin_enabled = true
}

resource "azurerm_kubernetes_cluster_node_pool" "private_node_pool" {
  name                = "private"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size             = "Standard_DS2_v2"
  node_count          = 1

  vnet_subnet_id = var.vnet_subnet_id
}

variable "resource_group_name" {
  description = "The name of the resource group"
}

variable "location" {
  description = "The location where resources will be deployed"
  default     = "East US"
}

variable "aks_cluster_name" {
  description = "The name of the AKS cluster"
}

variable "dns_prefix" {
  description = "The DNS prefix for the AKS cluster"
}

variable "acr_name" {
  description = "The name of the Azure Container Registry"
}

variable "vnet_subnet_id" {
  description = "The subnet ID for the private network"
}
