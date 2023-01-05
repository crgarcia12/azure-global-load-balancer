resource "azurerm_resource_group" "spoke_rg" {
  name     = "${var.prefix}-rg"
  location = "westeurope"
}

module "spoke_vnet" {
  source  = "./vnet"
  prefix = "${var.prefix}"
  location = var.location
  ip_second_octet = var.ip_second_octet
  resource_group_name = azurerm_resource_group.spoke_rg.name
  hub_vnet_rg_name = var.hub_rg_name
  hub_vnet_id = var.hub_vnet_id
  hub_vnet_name = var.hub_vnet_name
}

module "spoke_vm" {
  source  = "./vm"
  prefix = "${var.prefix}"
  location = var.location
  resource_group_name = azurerm_resource_group.spoke_rg.name
  #subnet_id = module.spoke_vnet.vnet_subnet_ids[1]
  subnet_id = module.spoke_vnet.vnet_vm_subnet_id
}

module "spoke_ars" {
  source  = "./routeserver"
  prefix = "${var.prefix}"
  location = var.location
  resource_group_name = azurerm_resource_group.spoke_rg.name
  subnet_id = module.spoke_vnet.vnet_ars_subnet_id
}