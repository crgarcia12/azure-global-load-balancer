terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.28.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "crgar-glb-terraform-rg"
    storage_account_name = "crgarglbterraformstor"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
provider "azurerm" {
  features {}
  subscription_id = var.SUBSCRIPTION_ID
}

locals {
  swe_hub_ars_bgp_peer_asn = 65111
  wus_hub_ars_bgp_peer_asn = 65222
}

#################################
#           hub-WUS
#################################
module "hub-wus" {
  source          = "./modules/hub"
  prefix          = "${var.prefix}-wus-hub"
  location        = "westus"
  ip_second_octet = "222"
  ssh_username    = var.SSH_USERNAME
  ssh_password    = var.SSH_PASSWORD
  vm_sku          = var.vm_sku
  deploy_bastion   = false
}

#################################
#           Spoke-WUS
#################################
# module "spoke_wus_s1" {
#   source          = "./modules/spoke"
#   prefix          = "${var.prefix}-wus-s1"
#   location        = "westus"
#   ip_second_octet = "223"
#   hub_vnet_name   = module.hub-wus.hub_vnet_name
#   hub_vnet_id     = module.hub-wus.hub_vnet_id
#   hub_rg_name     = module.hub-wus.hub_rg_name
#   ssh_username    = var.SSH_USERNAME
#   ssh_password    = var.SSH_PASSWORD
#   vm_sku = var.vm_sku
#   # [COST]  
#   fw_vip          = module.hub-wus.fw_vip

#   depends_on = [
#     module.hub-wus
#   ]
# }

#################################
#           Hub-SWE
#################################
module "hub_swe" {
  source          = "./modules/hub"
  prefix          = "${var.prefix}-swe-hub"
  location        = "swedencentral"
  ip_second_octet = "111"
  ssh_username    = var.SSH_USERNAME
  ssh_password    = var.SSH_PASSWORD
  vm_sku          = var.vm_sku
  deploy_bastion = true
}

#################################
#           Spokes-SWE
#################################
module "spoke_swe_s1" {
  source          = "./modules/spoke"
  prefix          = "${var.prefix}-swe-s1"
  location        = "swedencentral"
  ip_second_octet = "113"
  hub_vnet_name   = module.hub_swe.hub_vnet_name
  hub_vnet_id     = module.hub_swe.hub_vnet_id
  hub_rg_name     = module.hub_swe.hub_rg_name
  # [COST]  
  fw_vip       = module.hub_swe.fw_vip
  ssh_username = var.SSH_USERNAME
  ssh_password = var.SSH_PASSWORD
  vm_sku       = var.vm_sku
  depends_on = [
    module.hub_swe
  ]
}

#################################
#      BGP Configurations
#################################
# [COST]  
resource "azurerm_route_server_bgp_connection" "vm_wus_wus_bgpconnection" {
  name            = "${var.prefix}-wus-hub-vm-bgpconnection"
  route_server_id = module.hub-wus.hub_ars_id
  peer_asn        = local.wus_hub_ars_bgp_peer_asn
  peer_ip         = module.hub-wus.vm_private_ip_address
}

resource "azurerm_route_server_bgp_connection" "vm_wus_swe_bgpconnection" {
  name            = "${var.prefix}-swe-hub-vm-bgpconnection"
  route_server_id = module.hub_swe.hub_ars_id
  peer_asn        = local.wus_hub_ars_bgp_peer_asn
  peer_ip         = module.hub-wus.vm_private_ip_address
}


resource "azurerm_route_server_bgp_connection" "vm_swe_wus_bgpconnection" {
  name            = "${var.prefix}-weu-hub-vm-bgpconnection"
  route_server_id = module.hub-wus.hub_ars_id
  peer_asn        = local.swe_hub_ars_bgp_peer_asn
  peer_ip         = module.hub_swe.vm_private_ip_address
}

resource "azurerm_route_server_bgp_connection" "vm_swe_swe_bgpconnection" {
  name            = "${var.prefix}-weu-hub-vm-bgpconnection"
  route_server_id = module.hub_swe.hub_ars_id
  peer_asn        = local.swe_hub_ars_bgp_peer_asn
  peer_ip         = module.hub_swe.vm_private_ip_address
}


#################################
#           Hub Peerings
#################################

resource "azurerm_virtual_network_peering" "hub-hubswe" {
  name                      = "hub-hubswe"
  resource_group_name       = module.hub-wus.hub_rg_name
  virtual_network_name      = module.hub-wus.hub_vnet_name
  remote_virtual_network_id = module.hub_swe.hub_vnet_id
}

resource "azurerm_virtual_network_peering" "hubswe-hub" {
  name                      = "hubswe-hub"
  resource_group_name       = module.hub_swe.hub_rg_name
  virtual_network_name      = module.hub_swe.hub_vnet_name
  remote_virtual_network_id = module.hub-wus.hub_vnet_id
}
