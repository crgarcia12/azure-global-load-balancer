locals {
  vnet_name = "${var.prefix}-vnet"
}

#################################################
#      NSG
#################################################

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "nsg-ssh" {
  name                        = "allow-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "nsg-out-all" {
  name                        = "allow-out-all"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "nsg-in-all" {
  name                        = "allow-in-all"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
#################################################
#     UDR
#################################################
resource "azurerm_route_table" "udr" {
  name                          = "${var.prefix}-udr"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = true

  route {
    name                   = "route1"
    address_prefix         = "6.6.6.6/32"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.fw_vip
  }

  route {
    name                   = "fwdfirewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.fw_vip
  }
}

#################################################
#      Subnets
#################################################
/////////////    Default    /////////////////////
resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.${var.ip_second_octet}.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "default-nsg" {
  subnet_id                 = azurerm_subnet.default.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_route_table_association" "default-udr" {
  subnet_id      = azurerm_subnet.default.id
  route_table_id = azurerm_route_table.udr.id
}
////////////     VMS    /////////////////////////
resource "azurerm_subnet" "vms" {
  name                 = "vms"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.${var.ip_second_octet}.2.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "vms-nsg" {
  subnet_id                 = azurerm_subnet.vms.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_route_table_association" "vms-udr" {
  subnet_id      = azurerm_subnet.vms.id
  route_table_id = azurerm_route_table.udr.id
}
////////////    RouteServer    //////////////////
resource "azurerm_subnet" "RouteServerSubnet" {
  name                 = "RouteServerSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.${var.ip_second_octet}.3.0/24"]
}

////////////     AKS    /////////////////////
resource "azurerm_subnet" "aks" {
  name                 = "aks"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.${var.ip_second_octet}.4.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "aks-nsg" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_route_table_association" "aks-udr" {
  subnet_id      = azurerm_subnet.aks.id
  route_table_id = azurerm_route_table.udr.id
}
#################################################
#      VNET
#################################################

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.${var.ip_second_octet}.0.0/16"]

  tags = {
    environment = var.location
  }
}

resource "azurerm_virtual_network_peering" "spoke-hub" {
  name                      = "spoke2hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = local.vnet_name
  remote_virtual_network_id = var.hub_vnet_id
  use_remote_gateways       = true

  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_virtual_network_peering.hub-spoke
  ]
}

resource "azurerm_virtual_network_peering" "hub-spoke" {
  name                      = "hub2spoke-${var.prefix}"
  resource_group_name       = var.hub_vnet_rg_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
  allow_gateway_transit     = true
}
