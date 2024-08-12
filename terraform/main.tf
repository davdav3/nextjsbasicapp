provider "azurerm" {
  features {}
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.res-28.kube_config[0].host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.res-28.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.res-28.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.res-28.kube_config[0].cluster_ca_certificate)
  }
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
resource "azurerm_kubernetes_cluster_node_pool" "res-6" {
  enable_auto_scaling   = true
  eviction_policy       = "Delete"
  kubernetes_cluster_id = "/subscriptions/46108c1e-dcf5-466b-a16c-69228c6b310e/resourceGroups/deployment/providers/Microsoft.ContainerService/managedClusters/akshomeworkcluster"
  max_count             = 1
  min_count             = 1
  name                  = "userpool"
  node_taints           = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
  priority              = "Spot"
  vm_size               = var.vm_size_two
  depends_on = [
    azurerm_kubernetes_cluster.res-28,
  ]
}

resource "azurerm_nat_gateway" "res-12" {
  location            = azurerm_resource_group.rg.location
  name                = "deployment-nat-gw"
  resource_group_name = var.resource_group_name
  depends_on = [
    azurerm_resource_group.rg,
  ]
}
resource "azurerm_nat_gateway_public_ip_association" "res-13" {
  nat_gateway_id       = "/subscriptions/46108c1e-dcf5-466b-a16c-69228c6b310e/resourceGroups/deployment/providers/Microsoft.Network/natGateways/deployment-nat-gw"
  public_ip_address_id = "/subscriptions/46108c1e-dcf5-466b-a16c-69228c6b310e/resourceGroups/deployment/providers/Microsoft.Network/publicIPAddresses/deployment-nat-ip"
  depends_on = [
    azurerm_nat_gateway.res-12,
    azurerm_public_ip.res-17,
  ]
}
resource "azurerm_private_dns_zone" "res-14" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name
  depends_on = [
    azurerm_resource_group.rg,
  ]
}
resource "azurerm_private_dns_a_record" "res-15" {
  name                = var.acr_name
  records             = ["10.0.2.4"]
  resource_group_name = var.resource_group_name
  ttl                 = 300
  zone_name           = "privatelink.azurecr.io"
  depends_on = [
    azurerm_private_dns_zone.res-14,
  ]
}
resource "azurerm_public_ip" "res-17" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.rg.location
  name                = "deployment-nat-ip"
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  depends_on = [
    azurerm_resource_group.rg,
  ]
}
resource "azurerm_route_table" "res-18" {
  location            = azurerm_resource_group.rg.location
  name                = "deployment-aks-rt"
  resource_group_name = var.resource_group_name
  depends_on = [
    azurerm_resource_group.rg,
  ]
}
resource "azurerm_route" "res-19" {
  address_prefix      = "0.0.0.0/0"
  name                = "default-route"
  next_hop_type       = "Internet"
  resource_group_name = var.resource_group_name
  route_table_name    = "deployment-aks-rt"
  depends_on = [
    azurerm_route_table.res-18,
  ]
}
resource "azurerm_kubernetes_cluster" "res-28" {
  automatic_channel_upgrade           = "patch"
  dns_prefix                          = "akshomeworkcluster-dns"
  local_account_disabled              = true
  location                            = azurerm_resource_group.rg.location
  name                                = "akshomeworkcluster"
  private_cluster_enabled             = true
  private_cluster_public_fqdn_enabled = true
  resource_group_name                 = var.resource_group_name
  sku_tier                            = "Standard"
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    managed            = true
    tenant_id          = var.tenant_id != "" ? var.tenant_id : null
  }
  default_node_pool {
    enable_auto_scaling          = true
    max_count                    = 1
    min_count                    = 1
    name                         = "agentpool"
    only_critical_addons_enabled = true
    vm_size                      = var.vm_size_one
    upgrade_settings {
      max_surge = "10%"
    }
  }
  identity {
    type = "SystemAssigned"
  }
  maintenance_window_auto_upgrade {
    day_of_week = "Sunday"
    duration    = 4
    frequency   = "Weekly"
    interval    = 1
    start_time  = "00:00"
    utc_offset  = "+00:00"
  }
  maintenance_window_node_os {
    day_of_week = "Sunday"
    duration    = 4
    frequency   = "Weekly"
    interval    = 1
    start_time  = "00:00"
    utc_offset  = "+00:00"
  }
}
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name 
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"  
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"

  create_namespace = true

  set {
    name  = "controller.replicaCount"
    value = 2
  }

  set {
    name  = "controller.nodeSelector.agentpool"
    value = "userpool"
  }

  depends_on = [
    azurerm_kubernetes_cluster.res-28,
  ]
}
