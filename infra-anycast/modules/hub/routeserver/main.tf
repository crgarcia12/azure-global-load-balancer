
resource "azurerm_public_ip" "ars_ip" {
  name                = "${var.prefix}-ars-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_route_server" "ars" {
  name                             = "${var.prefix}-ars"
  location                         = var.location
  resource_group_name              = var.resource_group_name
  sku                              = "Standard"
  public_ip_address_id             = azurerm_public_ip.ars_ip.id
  subnet_id                        = var.subnet_id
  branch_to_branch_traffic_enabled = true
}

resource "azurerm_route_server_bgp_connection" "eastus-vm1-bgpconnection" {
  name            = "eastus-vm1-bgpconnection"
  route_server_id = azurerm_route_server.ars.id
  peer_asn        = 65111
  peer_ip         = "10.200.2.4"
}
