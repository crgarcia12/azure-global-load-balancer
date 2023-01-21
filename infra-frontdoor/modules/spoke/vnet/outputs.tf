output "vnet_vm_subnet_id" {
  value = azurerm_subnet.vms.id
}

output "vnet_aks_subnet_id" {
  value = azurerm_subnet.aks.id
}