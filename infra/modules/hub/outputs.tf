output "hub_vnet_id" {
  value = module.hub_vnet.vnet_id
}

output "hub_vnet_name" {
  value = module.hub_vnet.vnet_name
}

output "hub_rg_name" {
  value = azurerm_resource_group.hub_rg.name
}