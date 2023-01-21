output "vnet_vm_subnet_id" {
  value = azurerm_subnet.vms.id
}

output "vnet_fw_subnet_id" {
  value = azurerm_subnet.AzureFirewallSubnet.id
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}