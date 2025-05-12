resource "azurerm_storage_account" "storage" {
  name                = replace("${var.prefix}-stor", "-", "")
  resource_group_name = var.resource_group_name
  location            = var.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_private_endpoint" "endpoint" {
  name                = "${var.prefix}-stor-pe"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.subnet_id
  private_service_connection {
    name                           = "${var.prefix}-stor-psc"
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

resource "azurerm_private_dns_a_record" "dns_a" {
  name                = "${var.prefix}-stor"
  zone_name           = var.privatelink_storageblob_dns_zone_name
  resource_group_name = var.storage_dns_zone_rg
  ttl                 = 1
  records             = [azurerm_private_endpoint.endpoint.private_service_connection.0.private_ip_address]
}