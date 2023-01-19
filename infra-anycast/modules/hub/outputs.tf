output "hub_vnet_id" {
  value = module.hub_vnet.vnet_id
}

output "hub_vnet_name" {
  value = module.hub_vnet.vnet_name
}

output "fw_vip" {
  value = module.hub_fw.fw_vip
}

output "hub_rg_name" {
  value = azurerm_resource_group.hub_rg.name
}