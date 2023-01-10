locals {
  vnet_name = "${var.prefix}-vnet"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.${var.ip_second_octet}.0.0/16"]

  subnet {
    name           = "default"
    address_prefix = "10.${var.ip_second_octet}.1.0/24"
  }

  subnet {
    name           = "vms"
    address_prefix = "10.${var.ip_second_octet}.2.0/24"
    security_group = azurerm_network_security_group.nsg.id
  }

  tags = {
    environmsent = "${var.location}"
  }
}