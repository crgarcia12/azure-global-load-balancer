output "fw_vip" {
  value = azurerm_firewall.hub_fw.ip_configuration.private_ip_address
}
