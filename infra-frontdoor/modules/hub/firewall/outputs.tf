output "fw_vip" {
  value = azurerm_firewall.hub_fw.ip_configuration[0].private_ip_address
}
