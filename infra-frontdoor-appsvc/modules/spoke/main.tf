locals {
  resource_group_name = "${var.prefix}-rg"
}
resource "azurerm_resource_group" "spoke_rg" {
  name     = local.resource_group_name
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
  fw_vip              = var.fw_vip
}

module "spoke_vm" {
  count               = var.cost_reduction? 0 : 1
  source              = "./vm"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.spoke_rg.name
  subnet_id           = module.spoke_vnet.vnet_vm_subnet_id
  ssh_username        = var.ssh_username
  ssh_password        = var.ssh_password
}

module "app_svc" {
  count               = var.cost_reduction? 0 : 1
  source              = "./app-svc"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.spoke_rg.name
  subnet_id           = module.spoke_vnet.vnet_apps_subnet_id
}