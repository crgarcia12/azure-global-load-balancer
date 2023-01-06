output "vnet_vm_subnet_id" {
  # value = data.azurerm_subnet.vnet_subnets_data.*.id
  value = "${azurerm_virtual_network.vnet.id}/subnets/vms"
}

output "vnet_ars_subnet_id" {
  # value = data.azurerm_subnet.vnet_subnets_data.*.id
  value = "${azurerm_virtual_network.vnet.id}/subnets/RouteServerSubnet"
}

output "vnet_aks_subnet_id" {
  # value = data.azurerm_subnet.vnet_subnets_data.*.id
  value = "${azurerm_virtual_network.vnet.id}/subnets/aks"
}