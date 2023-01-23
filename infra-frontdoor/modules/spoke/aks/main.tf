locals {
  aks_name = "${var.prefix}-aks"
}

resource "azurerm_user_assigned_identity" "aks-msi" {
  name                = "${var.prefix}-aks-msi"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "aks-msi-assignment" {
  scope                = var.resource_group_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aks-msi.principal_id
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                      = local.aks_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  dns_prefix                = "${var.prefix}-aks"
  automatic_channel_upgrade = "stable"

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = var.subnet_id
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.aks-msi.id
    ]
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = ["10459d9f-98d8-48e0-b3fb-4f0b92a85ba4"]
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = var.network_plugin_mode
    ebpf_data_plane     = var.ebpf_data_plane
    load_balancer_sku   = "standard"
  }

  tags = {
    environment = var.location
  }

  depends_on = [
    azurerm_role_assignment.aks-msi-assignment
  ]
}
