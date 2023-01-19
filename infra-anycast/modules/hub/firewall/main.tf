
resource "azurerm_public_ip" "hub_fw_ip" {
  name                = "${var.prefix}-fw-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "hub_fw" {
  name                = "${var.prefix}-fw"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.hub_fw_ip.id
  }
}

resource "azurerm_firewall_network_rule_collection" "any-to-any-test" {
  name                = "netCollection1"
  azure_firewall_name = azurerm_firewall.hub_fw.name
  resource_group_name = var.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name = "testrule"

    source_addresses = [
      "10.0.0.0/8",
      "6.6.6.6/32"
    ]

    destination_ports = [
      "*",
    ]

    destination_addresses = [
      "10.0.0.0/8",
      "6.6.6.6/32"
    ]

    protocols = [
      "Any"
    ]
  }
}