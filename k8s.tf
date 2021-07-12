# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "kubernetes-sample" {
  name     = "k8s-resource-group"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "webapp-k8s" {
  name                = "webapp-aks1"
  location            = azurerm_resource_group.kubernetes-sample.location
  resource_group_name = azurerm_resource_group.kubernetes-sample.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "k8swebapp"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.webapp-k8s.kube_config.0.client_certificate
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.webapp-k8s.kube_config_raw
  sensitive = true
}

