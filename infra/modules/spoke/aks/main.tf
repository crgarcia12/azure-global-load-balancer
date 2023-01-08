resource "azurerm_kubernetes_cluster" "aks" {
  name                      = "${var.prefix}-aks"
  location                  = var.location
  resource_group_name       = var.resource_group_name
  dns_prefix                = "${var.prefix}-aks"
  automatic_channel_upgrade = "stable"

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_D2_v2"
    vnet_subnet_id  = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    managed = true
    admin_group_object_ids = [ "10459d9f-98d8-48e0-b3fb-4f0b92a85ba4" ]
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "Overlay"
    ebpf_data_plane     = "cilium"
    load_balancer_sku   = "standard"
  }
  
  tags = {
    environmsent = "${var.location}"
  }
}
