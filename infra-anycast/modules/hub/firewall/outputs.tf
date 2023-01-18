
output "fw_vip" {
  value = module.hub_fw.ip_configuration.private_ip_address
}
