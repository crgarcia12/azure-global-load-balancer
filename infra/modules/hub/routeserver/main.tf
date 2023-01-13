
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