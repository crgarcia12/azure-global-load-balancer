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
  disable_bgp_route_propagation = false

  route {
    name           = "route1"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "VnetLocal"
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

////////////    Firewall      //////////////////
resource "azurerm_subnet" "AzureFirewallSubnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.${var.ip_second_octet}.4.0/24"]
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