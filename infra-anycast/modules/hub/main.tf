resource "azurerm_resource_group" "hub_rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

module "hub_vnet" {
  source              = "./vnet"
  prefix              = var.prefix
  location            = var.location
  ip_second_octet     = var.ip_second_octet
  resource_group_name = azurerm_resource_group.hub_rg.name
}
module "hub_ars" {
  source              = "./routeserver"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  subnet_id           = module.hub_vnet.vnet_ars_subnet_id
}

# [COST] 
# module "hub_vm" {
#   source              = "./vm"
#   prefix              = var.prefix
#   location            = var.location
#   resource_group_name = azurerm_resource_group.hub_rg.name
#   subnet_id           = module.hub_vnet.vnet_vm_subnet_id
#   ssh_username        = var.ssh_username
#   ssh_password        = var.ssh_password
# }

# module "hub_fw" {
#   source              = "./firewall"
#   prefix              = var.prefix
#   location            = var.location
#   resource_group_name = azurerm_resource_group.hub_rg.name
#   subnet_id           = module.hub_vnet.vnet_fw_subnet_id
# }