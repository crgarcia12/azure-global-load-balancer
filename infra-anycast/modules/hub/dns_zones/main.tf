# Create Private DNS Zone
resource "azurerm_private_dns_zone" "privatelink_storageblob_dns_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

# Create Private DNS Zone Network Link
resource "azurerm_private_dns_zone_virtual_network_link" "network_link" {
  name                  = "hub-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_storageblob_dns_zone.name
  virtual_network_id    = var.vnet_id
}