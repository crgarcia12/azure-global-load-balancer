resource "azurerm_resource_group" "spoke_rg" {
  name     = "${var.prefix}-rg"
  location = "westeurope"
}

module "spoke_vnet" {
  source              = "./vnet"
  prefix              = var.prefix
  location            = var.location
  ip_second_octet     = var.ip_second_octet
  resource_group_name = azurerm_resource_group.spoke_rg.name
  hub_vnet_rg_name    = var.hub_rg_name
  hub_vnet_id         = var.hub_vnet_id
  hub_vnet_name       = var.hub_vnet_name
  # [COST] 
  # fw_vip              = var.fw_vip
}

module "spoke_vm" {
  source              = "./vm"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.spoke_rg.name
  subnet_id           = module.spoke_vnet.vnet_vm_subnet_id
  ssh_username        = var.ssh_username
  ssh_password        = var.ssh_password
}

# [COST] 
# module "aks" {
#   source              = "./aks"
#   prefix              = var.prefix
#   location            = var.location
#   resource_group_name = azurerm_resource_group.spoke_rg.name
#   resource_group_id   = azurerm_resource_group.spoke_rg.id
#   subnet_id           = module.spoke_vnet.vnet_aks_subnet_id
#   network_plugin_mode = var.aks_network_plugin_mode
#   ebpf_data_plane     = var.aks_ebpf_data_plane
# }